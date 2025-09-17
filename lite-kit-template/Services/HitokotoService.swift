import Foundation
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class HitokotoService: ObservableObject {
    // 公共状态
    @Published var currentHitokoto: Hitokoto?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdatedAt: Date?
    
    // 依赖注入
    private let session: URLSession
    private let baseURL: URL
    
    // 重试与缓存配置
    private let maxAttempts: Int = 2
    private let retryBaseDelay: TimeInterval = 0.6 // 秒
    private let cacheTTL: TimeInterval
    
    // 任务与缓存
    private var currentTask: Task<Void, Never>?
    private var cache: [CacheKey: (value: Hitokoto, timestamp: Date)] = [:]
    private var inflight: [CacheKey: Task<Hitokoto, Error>] = [:] // 并发合流
    
    // 磁盘缓存路径
    private lazy var cacheDirectoryURL: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("HitokotoCache", isDirectory: true)
    }()
    
    #if canImport(UIKit)
    private var memoryWarningObserver: NSObjectProtocol?
    #endif
    
    // MARK: - Init
    
    init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://v1.hitokoto.cn/")!,
        cacheTTL: TimeInterval = 60
    ) {
        self.session = session
        self.baseURL = baseURL
        self.cacheTTL = cacheTTL
        createCacheDirectoryIfNeeded()
        observeMemoryWarning()
    }
    
    deinit {
        currentTask?.cancel()
        #if canImport(UIKit)
        if let obs = memoryWarningObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        #endif
    }
    
    // MARK: - 对外 API（保持兼容）
    
    // 兼容入口：内部用 async 版本执行
    func fetchHitokoto(type: HitokotoType? = nil, forceRefresh: Bool = false) {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            await self?.fetchHitokotoAsync(type: type, forceRefresh: forceRefresh)
        }
    }
    
    // 新的 async/await 版本：缓存 + 并发合流 + 超时重试；失败时回退缓存
    func fetchHitokotoAsync(type: HitokotoType? = nil, forceRefresh: Bool = false) async {
        errorMessage = nil
        let key = CacheKey.from(type)
        
        // 先尝试命中缓存（内存/磁盘），避免首页首帧卡顿与“加载中”闪烁
        let memCached = cachedValue(for: key)
        let diskCached = (memCached == nil) ? await loadFromDiskAsync(for: key) : nil
        if !forceRefresh, let cached = memCached ?? diskCached {
            currentHitokoto = cached
            isLoading = false
            return
        }
        
        isLoading = true
        
        do {
            // 并发合流：若已有同 key 的在飞请求，直接等待它
            if let task = inflight[key] {
                let value = try await task.value
                currentHitokoto = value
                cache[key] = (value, Date())
                lastUpdatedAt = Date()
                saveToDisk(value, for: key)
                isLoading = false
                return
            }
            
            // 创建新的网络任务，并登记为 in-flight
            let task = Task { () throws -> Hitokoto in
                try await self.requestOnce(type: type, attempt: 1)
            }
            inflight[key] = task
            defer { inflight.removeValue(forKey: key) }
            
            let value = try await task.value
            currentHitokoto = value
            cache[key] = (value, Date())
            lastUpdatedAt = Date()
            saveToDisk(value, for: key)
            isLoading = false
        } catch is CancellationError {
            isLoading = false
        } catch {
            // 离线兜底：若磁盘/内存中仍有有效缓存，展示缓存并提示
            // 注意这里再次尝试磁盘（异步），避免主线程阻塞
            let fallbackDisk = await loadFromDiskAsync(for: key)
            if let fallback = cachedValue(for: key) ?? fallbackDisk {
                currentHitokoto = fallback
                errorMessage = "网络异常，已展示缓存内容。"
            } else {
                errorMessage = Self.prettyMessage(for: error)
            }
            isLoading = false
        }
    }
    
    // 主动失效指定分类缓存/全部缓存
    func invalidateCache(for type: HitokotoType?) {
        let key = CacheKey.from(type)
        cache.removeValue(forKey: key)
        removeDiskCache(for: key)
    }
    
    func invalidateAllCache() {
        cache.removeAll()
        removeAllDiskCache()
    }
    
    // 清理已过期的内存缓存（不会触碰磁盘）
    func clearExpiredMemoryCache() {
        let now = Date()
        cache = cache.filter { now.timeIntervalSince($0.value.timestamp) <= cacheTTL }
    }
    
    // MARK: - 私有实现
    
    private func requestOnce(type: HitokotoType?, attempt: Int) async throws -> Hitokoto {
        // 构造 URL
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        if let type = type {
            components.queryItems = [URLQueryItem(name: "c", value: type.rawValue)]
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 10
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }
            // 在后台线程解码，避免阻塞主线程
            let decoded = try await Self.decodeHitokotoAsync(from: data)
            return decoded
        } catch {
            // 简单重试：最大 maxAttempts 次，指数退避
            if attempt < maxAttempts {
                let delay = retryBaseDelay * pow(2.0, Double(attempt - 1))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await requestOnce(type: type, attempt: attempt + 1)
            } else {
                throw error
            }
        }
    }
    
    private func cachedValue(for key: CacheKey) -> Hitokoto? {
        guard let entry = cache[key] else { return nil }
        if Date().timeIntervalSince(entry.timestamp) <= cacheTTL {
            return entry.value
        } else {
            cache.removeValue(forKey: key)
            return nil
        }
    }
    
    private nonisolated static func prettyMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "网络未连接，请检查后重试。"
            case .timedOut:
                return "请求超时，请稍后再试。"
            case .cannotFindHost, .cannotConnectToHost:
                return "无法连接到服务器。"
            default:
                break
            }
        }
        return "获取失败: \(error.localizedDescription)"
    }
    
    // MARK: - 磁盘缓存（异步）
    
    private struct DiskEntry: Codable {
        let value: Hitokoto
        let timestamp: Date
    }
    
    private func createCacheDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
        } catch {
            // 目录创建失败不影响功能（仅失去磁盘缓存）
        }
    }
    
    private func fileName(for key: CacheKey) -> String {
        switch key {
        case .all: return "all.json"
        case .type(let t): return "type-\(t.rawValue).json"
        }
    }
    
    private func diskURL(for key: CacheKey) -> URL {
        cacheDirectoryURL.appendingPathComponent(fileName(for: key))
    }
    
    private func saveToDisk(_ value: Hitokoto, for key: CacheKey) {
        let entry = DiskEntry(value: value, timestamp: Date())
        let url = diskURL(for: key)
        Task.detached(priority: .utility) {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(entry)
                try data.write(to: url, options: .atomic)
            } catch {
                // 写入失败静默
            }
        }
    }
    
    private func loadFromDisk(for key: CacheKey) -> Hitokoto? {
        let url = diskURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let entry = try JSONDecoder().decode(DiskEntry.self, from: data)
            if Date().timeIntervalSince(entry.timestamp) <= cacheTTL {
                return entry.value
            } else {
                try? FileManager.default.removeItem(at: url)
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // 后台线程读取磁盘，避免阻塞主线程
    private func loadFromDiskAsync(for key: CacheKey) async -> Hitokoto? {
        await Task.detached(priority: .utility) { [cacheTTL] in
            let url = await self.diskURL(for: key)
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            do {
                let data = try Data(contentsOf: url)
                let entry = try JSONDecoder().decode(DiskEntry.self, from: data)
                if Date().timeIntervalSince(entry.timestamp) <= cacheTTL {
                    return entry.value
                } else {
                    try? FileManager.default.removeItem(at: url)
                    return nil
                }
            } catch {
                return nil
            }
        }.value
    }
    
    // 后台线程 JSON 解码
    private nonisolated static func decodeHitokotoAsync(from data: Data) async throws -> Hitokoto {
        try await Task.detached(priority: .utility) {
            try JSONDecoder().decode(Hitokoto.self, from: data)
        }.value
    }
    
    private func removeDiskCache(for key: CacheKey) {
        let url = diskURL(for: key)
        try? FileManager.default.removeItem(at: url)
    }
    
    private func removeAllDiskCache() {
        try? FileManager.default.removeItem(at: cacheDirectoryURL)
        createCacheDirectoryIfNeeded()
    }
    
    // MARK: - 系统事件
    
    private func observeMemoryWarning() {
        #if canImport(UIKit)
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
        #endif
    }
    
    private func handleMemoryWarning() {
        // 收到内存告警时，直接清空内存缓存（磁盘缓存保留）
        cache.removeAll()
    }
}

// 缓存键（支持“全部”与某分类）
private enum CacheKey: Hashable {
    case all
    case type(HitokotoType)
    
    static func from(_ type: HitokotoType?) -> CacheKey {
        if let t = type { return .type(t) }
        return .all
    }
}
