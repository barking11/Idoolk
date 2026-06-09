import SwiftUI
import Combine

class LoadingManager: ObservableObject {
    static let shared = LoadingManager()
    
    @Published var isLoading = false
    @Published var message: String?
    @Published var customImage: String?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // 安全地设置加载状态
    func setLoading(_ loading: Bool, message: String? = nil, customImage: String? = nil) {
        // 确保在主线程上更新UI状态
        DispatchQueue.main.async {
            self.isLoading = loading
            self.message = message
            self.customImage = customImage ?? self.customImage
        }
    }
    
    // Show loading with optional timeout
    func showLoading(message: String? = nil, customImage: String? = nil, timeout: Double? = nil) {
        // 使用安全的方法设置状态
        setLoading(true, message: message, customImage: customImage)
        
        // Auto hide after timeout if specified
        if let timeout = timeout {
            Just(())
                .delay(for: .seconds(timeout), scheduler: RunLoop.main)
                .sink { [weak self] _ in
                    self?.hideLoading()
                }
                .store(in: &cancellables)
        }
    }
    
    // Hide loading
    func hideLoading() {
        // 使用安全的方法设置状态
        self.setLoading(false)
    }
    
    // Show loading during a network request
    func withLoading<T, E: Error>(
        message: String? = nil,
        customImage: String? = "loading_icon",
        publisher: AnyPublisher<T, E>
    ) -> AnyPublisher<T, E> {
        showLoading(message: message, customImage: customImage)
        
        return publisher
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.hideLoading()
            }, receiveCancel: { [weak self] in
                self?.hideLoading()
            })
            .eraseToAnyPublisher()
    }
} 
