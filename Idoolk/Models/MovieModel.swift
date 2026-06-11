import Foundation
import Combine

struct Movie: Identifiable, Codable, Equatable {
    let adult: Bool
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let originCountry: [String]?
    let originalLanguage: String
    let originalName: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let firstAirDate: String
    let name: String
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview
        case popularity
        case posterPath = "poster_path"
        case firstAirDate = "first_air_date"
        case name
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
}

struct MovieSection: Identifiable {
    let id = UUID()
    let title: String
    let movies: [Movie]
    
    static let genreMap: [Int: String] = [
        18: "剧情",
        10759: "动作冒险",
        35: "喜剧",
        80: "犯罪",
        99: "纪录",
        10751: "家庭",
        14: "奇幻",
        36: "历史",
        27: "恐怖",
        10762: "儿童",
        10763: "新闻",
        10764: "真人秀",
        10765: "科幻",
        10766: "肥皂剧",
        10767: "脱口秀",
        10768: "战争与政治",
        37: "西部",
        9648: "悬疑"
    ]
    
    static func getGenreString(for ids: [Int]) -> String {
        return ids.compactMap { genreMap[$0] }.joined(separator: "·")
    }
}

class MovieViewModel: ObservableObject {
    @Published var sections: [MovieSection] = []
    @Published var banners: [HomeBanner] = []
    @Published var movieGroups: [MovieGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // 保存取消器以防止内存泄漏
    private var cancellables = Set<AnyCancellable>()
    
//    init() {
//        loadData()
//    }
    
    func loadData() {
        // 设置本地加载状态
        isLoading = true
        errorMessage = nil
        
        // 使用API服务获取数据，并通过LoadingManager管理加载状态
        LoadingManager.shared.withLoading(
            message: "加载中...",
            publisher: APIService.shared.fetchHomeData()
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.message
                }
            },
            receiveValue: { [weak self] response in
                self?.processFetchedData(response)
            }
        )
        .store(in: &cancellables)
    }
    
     func processFetchedData(_ response: HomeResponse) {
        // 处理从API获取的数据
        var newSections: [MovieSection] = []
        
        banners = response.banner
        
        // 处理最新上线
        let newMovies = response.newcome.map { $0.toMovie() }
        if !newMovies.isEmpty {
            newSections.append(MovieSection(title: "最新上线", movies: newMovies))
        }
        
        // 处理热播剧
        let hotMovies = response.hot.map { $0.toMovie() }
        if !hotMovies.isEmpty {
            newSections.append(MovieSection(title: "热播剧", movies: hotMovies))
        }

        // 处理高分剧集
        let topRatedMovies = response.topRated.map { $0.toMovie() }
        if !topRatedMovies.isEmpty {
            newSections.append(MovieSection(title: "高分剧集", movies: topRatedMovies))
        }
        
        // 保存电影分组数据
        movieGroups = response.group
        
        // 如果没有获取到数据，尝试加载本地模拟数据
        if newSections.isEmpty {

        } else {
            // 更新数据
            sections = newSections
        }
    }
    
    // Image URL helper
    func getImageURL(path: String?, size: String = "w500") -> URL? {
        guard let path = path else { return nil }
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return URL(string: path)
        }
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
    }
    
    // 获取评论信息
    func getReviewFor(movie: Movie, in response: HomeResponse) -> Movie.Review? {
        if let banner = response.banner.first(where: { $0.targetTitle?.id == movie.id }),
           let name = banner.userNickname,
           let content = banner.comment {
            return Movie.Review(name: name, content: content)
        }
        return nil
    }
    
} 
