import Foundation
import Alamofire
import Combine
import SwiftUI // 确保已导入SwiftUI

// 定义AI影评响应模型
struct AIReviewResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [AIChoice]
    let usage: AIUsage
    let systemFingerprint: String
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

struct AIChoice: Codable {
    let index: Int
    let message: AIMessage
    let finishReason: String
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct AIMessage: Codable {
    let role: String
    let content: String
}

struct AIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// 统一API接口错误类型
enum APIError: Error {
    case networkError(AFError)
    case decodingError(Error)
    case invalidURL
    case invalidResponse
    case emptyData
    case cacheError
    case unknown(Error)
    
    var message: String {
        switch self {
        case .networkError(let error):
            return "网络请求错误: \(error.localizedDescription)"
        case .decodingError(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .emptyData:
            return "返回数据为空"
        case .cacheError:
            return "缓存读取错误"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
}

// API服务类
class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://home-f30809.gitlab.io"
    private let tmdbBaseURL = "https://api.tmdb.org/3"
    private let tmdbApiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyYzFkMjAxMmYzYmJiYWRmZTI1ZGQ4OTEwMDA5MDkxNSIsIm5iZiI6MTc0MTc2MDYxMy44MjA5OTk5LCJzdWIiOiI2N2QxMjg2NWI1ZWUwZTM5N2M2MGJkYzYiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.-34tNmfL34IATdvvuTZtXOrAe9H1VYvF-K8u9rtJ6Ds"
    private let session: Session
    private let cache = NSCache<NSString, NSData>()
    private let cacheExpiration: TimeInterval = 30 * 60 // 缓存30分钟
    
    private var lastFetchTime: [String: Date] = [:]
    
    private init() {
        // 配置Alamofire
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0 // 请求超时时间
        configuration.timeoutIntervalForResource = 30.0 // 资源获取超时时间
        
        session = Session(configuration: configuration)
        
        // 配置缓存
        cache.countLimit = 20 // 最多缓存20个响应
        cache.totalCostLimit = 10 * 1024 * 1024 // 最大缓存10MB
    }
    
    // 获取首页数据（支持缓存）
    func fetchHomeData() -> AnyPublisher<HomeResponse, APIError> {
        let cacheKey = "home_data" as NSString
        let urlString = baseURL
        
        // 检查是否有有效缓存
        if let cachedData = cache.object(forKey: cacheKey) as Data?,
           let lastFetch = lastFetchTime[cacheKey as String],
           Date().timeIntervalSince(lastFetch) < cacheExpiration {
            
            do {
                let decoder = JSONDecoder()
                let cachedResponse = try decoder.decode(HomeResponse.self, from: cachedData)
                return Just(cachedResponse)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            } catch {
                // 缓存解码失败，继续网络请求
                print("缓存解码失败: \(error.localizedDescription)")
            }
        }
        
        // 构建URL
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // 使用withLoading包装网络请求
        let networkPublisher = session.request(url, method: .get)
            .validate()
            .publishDecodable(type: HomeResponse.self)
            .tryMap { response in
                // 确保响应有值
                guard let value = response.value else {
                    if let error = response.error {
                        throw APIError.networkError(error)
                    } else {
                        throw APIError.emptyData
                    }
                }
                
                // 缓存响应数据
                if let data = response.data {
                    self.cache.setObject(data as NSData, forKey: cacheKey)
                    self.lastFetchTime[cacheKey as String] = Date()
                }
                
                return value
            }
            .mapError { error in
                if let afError = error as? AFError {
                    return APIError.networkError(afError)
                } else if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.unknown(error)
                }
            }
            .eraseToAnyPublisher()
            
        // 自动处理加载状态，这里不使用LoadingManager的withLoading，因为我们要在MovieViewModel中控制加载状态
        return networkPublisher
    }
    
    // 获取电视剧详情（支持缓存）
    func fetchTVShowDetail(id: Int, language: String = "zh-CN") -> AnyPublisher<TVShowDetailResponse, APIError> {
        let cacheKey = "tv_detail_\(id)_\(language)" as NSString
        
        // 检查是否有有效缓存
        if let cachedData = cache.object(forKey: cacheKey) as Data?,
           let lastFetch = lastFetchTime[cacheKey as String],
           Date().timeIntervalSince(lastFetch) < cacheExpiration {
            
            do {
                let decoder = JSONDecoder()
                let cachedResponse = try decoder.decode(TVShowDetailResponse.self, from: cachedData)
                return Just(cachedResponse)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            } catch {
                print("缓存解码失败: \(error.localizedDescription)")
            }
        }
        
        // 构建URL
        let urlString = "\(tmdbBaseURL)/tv/\(id)"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // 构建参数
        let parameters: Parameters = [
            "append_to_response": "credits,recommendations",
            "language": language
        ]
        
        // 构建header
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(tmdbApiKey)"
        ]
        
        // 发起网络请求
        let networkPublisher = session.request(
            url,
            method: .get,
            parameters: parameters,
            headers: headers
        )
        .validate()
        .publishDecodable(type: TVShowDetailResponse.self)
        .tryMap { response in
            // 确保响应有值
            guard let value = response.value else {
                if let error = response.error {
                    throw APIError.networkError(error)
                } else {
                    throw APIError.emptyData
                }
            }
            
            // 缓存响应数据
            if let data = response.data {
                self.cache.setObject(data as NSData, forKey: cacheKey)
                self.lastFetchTime[cacheKey as String] = Date()
            }
            
            return value
        }
        .mapError { error in
            if let afError = error as? AFError {
                return APIError.networkError(afError)
            } else if let apiError = error as? APIError {
                return apiError
            } else {
                return APIError.unknown(error)
            }
        }
        .eraseToAnyPublisher()
        
        return networkPublisher
    }
    
    // 搜索电视剧
    func searchMovies(query: String, page: Int = 1, language: String = "zh-CN") -> AnyPublisher<SearchResponse, APIError> {
        let cacheKey = "search_\(query)_\(page)_\(language)" as NSString
        
        // 检查是否有有效缓存
        if let cachedData = cache.object(forKey: cacheKey) as Data?,
           let lastFetch = lastFetchTime[cacheKey as String],
           Date().timeIntervalSince(lastFetch) < cacheExpiration {
            
            do {
                let decoder = JSONDecoder()
                let cachedResponse = try decoder.decode(SearchResponse.self, from: cachedData)
                return Just(cachedResponse)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            } catch {
                print("缓存解码失败: \(error.localizedDescription)")
            }
        }
        
        // 构建URL
        let urlString = "\(tmdbBaseURL)/search/tv"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // 构建参数
        let parameters: Parameters = [
            "query": query,
            "include_adult": "false",
            "language": language,
            "page": String(page)
        ]
        
        // 构建header
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(tmdbApiKey)"
        ]
        
        // 发起网络请求
        let networkPublisher = session.request(
            url,
            method: .get,
            parameters: parameters,
            headers: headers
        )
        .validate()
        .publishDecodable(type: SearchResponse.self)
        .tryMap { response in
            // 确保响应有值
            guard let value = response.value else {
                if let error = response.error {
                    throw APIError.networkError(error)
                } else {
                    throw APIError.emptyData
                }
            }
            
            // 缓存响应数据
            if let data = response.data {
                self.cache.setObject(data as NSData, forKey: cacheKey)
                self.lastFetchTime[cacheKey as String] = Date()
            }
            
            return value
        }
        .mapError { error in
            if let afError = error as? AFError {
                return APIError.networkError(afError)
            } else if let apiError = error as? APIError {
                return apiError
            } else {
                return APIError.unknown(error)
            }
        }
        .eraseToAnyPublisher()
        
        return networkPublisher
    }
    
    // AI影评接口
    func fetchAIReview(movieName: String, reviewer: AIReviewer) -> AnyPublisher<AIReviewResponse, APIError> {
        // 构建URL
        let urlString = "https://api.siliconflow.cn/v1/chat/completions"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // 根据影评人构建不同的prompt
        let prompt: String
        switch reviewer {
        case .shenZhiYuan:
            prompt = "您是一位专业学术派影评人沈知远，擅长剖析叙事结构与文化背景，评论深入理性。请以这个身份，用中文对电视剧《\(movieName)》进行一篇300字左右的专业评价，注重分析其叙事手法、主题表达、社会意义和艺术价值。"
        case .taoQiQi:
            prompt = "您是一位感性大众派影评人桃柒柒，评论直白易懂，常带迷妹视角与情绪化表达。请以这个身份，用中文对电视剧《\(movieName)》进行一篇200字左右的评价，可以加入一些俏皮的语言，表达您对剧中人物和情节的喜爱或不满，让普通观众能够产生共鸣。"
        case .zhangDaiFu:
            prompt = "您是一位毒舌犀利派影评人张戴夫，善抓槽点，评论风格尖锐，常带批判性。请以这个身份，用中文对电视剧《\(movieName)》进行一篇200字左右的评价，直言不讳地指出该剧存在的问题和槽点，但也客观地提出其值得肯定的地方。"
        }
        
        // 构建请求参数
        let parameters: Parameters = [
            "model": "Qwen/Qwen2.5-7B-Instruct",
            "stream": false,
            "max_tokens": 512,
            "temperature": 0.7,
            "top_p": 0.7,
            "top_k": 50,
            "frequency_penalty": 0.5,
            "n": 1,
            "stop": [],
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        // 构建header
        let headers: HTTPHeaders = [
            "Authorization": "Bearer sk-rqkotnilzqrcrhuojkevcepqpwgxzzxcrkodywunqrjqcarr",
            "Content-Type": "application/json"
        ]
        
        // 发起网络请求
        return session.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .validate()
        .publishDecodable(type: AIReviewResponse.self)
        .tryMap { response in
            // 确保响应有值
            guard let value = response.value else {
                if let error = response.error {
                    throw APIError.networkError(error)
                } else {
                    throw APIError.emptyData
                }
            }
            return value
        }
        .mapError { error in
            if let afError = error as? AFError {
                return APIError.networkError(afError)
            } else if let apiError = error as? APIError {
                return apiError
            } else {
                return APIError.unknown(error)
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 清除缓存
    func clearCache() {
        cache.removeAllObjects()
        lastFetchTime.removeAll()
    }
}

