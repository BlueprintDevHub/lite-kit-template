import Foundation
import Combine

class HitokotoService: ObservableObject {
    @Published var currentHitokoto: Hitokoto?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchHitokoto(type: HitokotoType? = nil) {
        isLoading = true
        errorMessage = nil
        
        var urlString = "https://v1.hitokoto.cn/"
        if let type = type {
            urlString += "?c=\(type.rawValue)"
        }
        
        guard let url = URL(string: urlString) else {
            errorMessage = "无效的URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Hitokoto.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "获取失败: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] hitokoto in
                    self?.currentHitokoto = hitokoto
                }
            )
            .store(in: &cancellables)
    }
}