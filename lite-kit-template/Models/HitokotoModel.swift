import Foundation

/// 一言数据模型
/// - 注意：保留了后端的原始字段命名（如 `from_who`、`created_at`、`type` 字符串）
///   以避免影响现有代码（例如 HomeView/HitokotoCard 的直接访问）
/// - 新增：
///   - `createdAt`：把 `created_at` 字符串尽力解析为 `Date`
///   - `typeEnum`：把 `type` 的单字母代码转换为 `HitokotoType`
///   - `fromWho`：`from_who` 的 camelCase 便捷访问
struct Hitokoto: Codable, Identifiable {
    // 原始字段（与后端 JSON 一致）
    let id: Int
    let uuid: String
    let hitokoto: String
    let type: String
    let from: String
    let from_who: String?
    let creator: String
    let creator_uid: Int
    let reviewer: Int
    let commit_from: String
    let created_at: String
    let length: Int
    
    // 改进：解码后的时间
    let createdAt: Date?
    
    // 改进：便捷属性
    var typeEnum: HitokotoType? { HitokotoType(rawValue: type) }
    var fromWho: String? { from_who }
    
    // 自定义解码以支持 createdAt
    private enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case hitokoto
        case type
        case from
        case from_who
        case creator
        case creator_uid
        case reviewer
        case commit_from
        case created_at
        case length
    }
    
    init(
        id: Int,
        uuid: String,
        hitokoto: String,
        type: String,
        from: String,
        from_who: String?,
        creator: String,
        creator_uid: Int,
        reviewer: Int,
        commit_from: String,
        created_at: String,
        length: Int,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.uuid = uuid
        self.hitokoto = hitokoto
        self.type = type
        self.from = from
        self.from_who = from_who
        self.creator = creator
        self.creator_uid = creator_uid
        self.reviewer = reviewer
        self.commit_from = commit_from
        self.created_at = created_at
        self.length = length
        self.createdAt = createdAt ?? DateParsers.parse(created_at)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.hitokoto = try container.decode(String.self, forKey: .hitokoto)
        self.type = try container.decode(String.self, forKey: .type)
        self.from = try container.decode(String.self, forKey: .from)
        self.from_who = try container.decodeIfPresent(String.self, forKey: .from_who)
        self.creator = try container.decode(String.self, forKey: .creator)
        self.creator_uid = try container.decode(Int.self, forKey: .creator_uid)
        self.reviewer = try container.decode(Int.self, forKey: .reviewer)
        self.commit_from = try container.decode(String.self, forKey: .commit_from)
        self.created_at = try container.decode(String.self, forKey: .created_at)
        self.length = try container.decode(Int.self, forKey: .length)
        
        // 改进：尝试把 created_at 转成 Date
        self.createdAt = DateParsers.parse(self.created_at)
    }
}

/// 一言分类
enum HitokotoType: String, CaseIterable {
    case anime = "a"
    case comic = "b"
    case game = "c"
    case literature = "d"
    case original = "e"
    case internet = "f"
    case other = "g"
    case movie = "h"
    case poetry = "i"
    case netease = "j"
    case philosophy = "k"
    case funny = "l"
    
    var displayName: String {
        switch self {
        case .anime: return "动画"
        case .comic: return "漫画"
        case .game: return "游戏"
        case .literature: return "文学"
        case .original: return "原创"
        case .internet: return "来自网络"
        case .other: return "其他"
        case .movie: return "影视"
        case .poetry: return "诗词"
        case .netease: return "网易云"
        case .philosophy: return "哲学"
        case .funny: return "抖机灵"
        }
    }
}

// MARK: - Date Parsing Helpers

private enum DateParsers {
    // 尽量复用静态格式器，避免频繁创建带来的性能开销
    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return f
    }()
    
    private static let iso8601Fractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFractionalSeconds]
        return f
    }()
    
    private static func df(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = format
        return f
    }
    
    private static let candidates: [DateFormatter] = [
        df("yyyy-MM-dd HH:mm:ss"),
        df("yyyy/MM/dd HH:mm:ss"),
        df("yyyy-MM-dd'T'HH:mm:ssZ"),
        df("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    ]
    
    static func parse(_ string: String) -> Date? {
        // 先试 ISO8601（带/不带毫秒）
        if let d = iso8601.date(from: string) { return d }
        if let d = iso8601Fractional.date(from: string) { return d }
        // 再试常见自定义格式
        for f in candidates {
            if let d = f.date(from: string) { return d }
        }
        return nil
    }
}
