import Foundation

// 首页接口响应模型
struct HomeResponse: Codable {
    let banner: [MovieDTO]
    let newcome: [MovieDTO]
    let hot: [MovieDTO]
    let group: [MovieGroup]
    
    // 添加默认值，防止解码失败
    init(banner: [MovieDTO] = [], newcome: [MovieDTO] = [], hot: [MovieDTO] = [], group: [MovieGroup] = []) {
        self.banner = banner
        self.newcome = newcome
        self.hot = hot
        self.group = group
    }
}

struct MovieGroup: Codable {
    let title: String
    let desc: String
    let cover: String
    let list: [MovieDTO]
    
    init(title: String = "", desc: String = "", cover: String = "", list: [MovieDTO] = []) {
        self.title = title
        self.desc = desc
        self.cover = cover
        self.list = list
    }
}

// API返回的电影数据模型
struct MovieDTO: Codable, Identifiable {
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
    let reviewName: String?
    let reviewContent: String?
    
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
        case reviewName = "review_name"
        case reviewContent = "review_content"
    }
    
    // 转换为应用中使用的Movie模型
    func toMovie() -> Movie {
        return Movie(
            adult: adult,
            backdropPath: backdropPath,
            genreIds: genreIds,
            id: id,
            originCountry: originCountry,
            originalLanguage: originalLanguage,
            originalName: originalName,
            overview: overview,
            popularity: popularity,
            posterPath: posterPath,
            firstAirDate: firstAirDate,
            name: name,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
}

// 扩展Movie模型，添加用户评论信息
extension Movie {
    // 用户评论数据
    struct Review {
        let name: String
        let content: String
    }
    
    // 获取评论(如果有)
    func getReview(from dto: MovieDTO) -> Review? {
        guard let name = dto.reviewName, let content = dto.reviewContent else {
            return nil
        }
        return Review(name: name, content: content)
    }
}

// 搜索结果响应模型
struct SearchResponse: Codable {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
