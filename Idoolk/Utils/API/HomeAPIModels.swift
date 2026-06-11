import Foundation

// 首页接口响应模型
struct HomeResponse: Decodable {
    let banner: [HomeBanner]
    let newcome: [MovieDTO]
    let hot: [MovieDTO]
    let topRated: [MovieDTO]
    let group: [MovieGroup]
    
    // 添加默认值，防止解码失败
    init(
        banner: [HomeBanner] = [],
        newcome: [MovieDTO] = [],
        hot: [MovieDTO] = [],
        topRated: [MovieDTO] = [],
        group: [MovieGroup] = []
    ) {
        self.banner = banner
        self.newcome = newcome
        self.hot = hot
        self.topRated = topRated
        self.group = group
    }
}

struct HomeBanner: Decodable, Identifiable {
    let id: String
    let title: String
    let imageUrl: String
    let userNickname: String?
    let comment: String?
    let targetType: String
    let targetId: String?
    let linkUrl: String?
    let targetTitle: MovieDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageUrl
        case userNickname
        case comment
        case targetType
        case targetId
        case targetTitleId
        case linkUrl
        case targetTitle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        userNickname = try container.decodeIfPresent(String.self, forKey: .userNickname)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        targetType = try container.decodeIfPresent(String.self, forKey: .targetType) ?? "NONE"
        targetId = try container.decodeIfPresent(String.self, forKey: .targetId)
            ?? container.decodeIfPresent(String.self, forKey: .targetTitleId)
        linkUrl = try container.decodeIfPresent(String.self, forKey: .linkUrl)
        targetTitle = try container.decodeIfPresent(MovieDTO.self, forKey: .targetTitle)
    }
    
    var targetMovie: Movie? {
        targetTitle?.toMovie()
    }
}

struct MovieGroup: Decodable {
    let id: String?
    let title: String
    let desc: String
    let coverUrl: String
    let list: [MovieDTO]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case desc
        case description
        case coverUrl
        case cover
        case list
    }
    
    init(id: String? = nil, title: String = "", desc: String = "", coverUrl: String = "", list: [MovieDTO] = []) {
        self.id = id
        self.title = title
        self.desc = desc
        self.coverUrl = coverUrl
        self.list = list
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        desc = try container.decodeIfPresent(String.self, forKey: .description)
            ?? container.decodeIfPresent(String.self, forKey: .desc)
            ?? ""
        coverUrl = try container.decodeIfPresent(String.self, forKey: .coverUrl)
            ?? container.decodeIfPresent(String.self, forKey: .cover)
            ?? ""
        list = try container.decodeIfPresent([MovieDTO].self, forKey: .list) ?? []
    }
}

// API返回的电影数据模型
struct MovieDTO: Decodable, Identifiable {
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
        case backdropUrl
        case backdropPathSnake = "backdrop_path"
        case genreIdsCamel = "genreIds"
        case genreIdsSnake = "genre_ids"
        case id
        case originCountryCamel = "originCountry"
        case originCountrySnake = "origin_country"
        case originalLanguageCamel = "originalLanguage"
        case originalLanguageSnake = "original_language"
        case originalNameCamel = "originalName"
        case originalNameSnake = "original_name"
        case overview
        case popularity
        case posterUrl
        case posterPathSnake = "poster_path"
        case firstAirDateCamel = "firstAirDate"
        case firstAirDateSnake = "first_air_date"
        case name
        case voteAverageCamel = "voteAverage"
        case voteAverageSnake = "vote_average"
        case voteCountCamel = "voteCount"
        case voteCountSnake = "vote_count"
        case reviewNameCamel = "reviewName"
        case reviewNameSnake = "review_name"
        case reviewContentCamel = "reviewContent"
        case reviewContentSnake = "review_content"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        adult = try container.decodeIfPresent(Bool.self, forKey: .adult) ?? false
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropUrl)
            ?? container.decodeIfPresent(String.self, forKey: .backdropPathSnake)
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIdsCamel)
            ?? container.decodeIfPresent([Int].self, forKey: .genreIdsSnake)
            ?? []
        id = try container.decode(Int.self, forKey: .id)
        originCountry = try container.decodeIfPresent([String].self, forKey: .originCountryCamel)
            ?? container.decodeIfPresent([String].self, forKey: .originCountrySnake)
        originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguageCamel)
            ?? container.decodeIfPresent(String.self, forKey: .originalLanguageSnake)
            ?? ""
        originalName = try container.decodeIfPresent(String.self, forKey: .originalNameCamel)
            ?? container.decodeIfPresent(String.self, forKey: .originalNameSnake)
            ?? ""
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity) ?? 0
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterUrl)
            ?? container.decodeIfPresent(String.self, forKey: .posterPathSnake)
        firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDateCamel)
            ?? container.decodeIfPresent(String.self, forKey: .firstAirDateSnake)
            ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverageCamel)
            ?? container.decodeIfPresent(Double.self, forKey: .voteAverageSnake)
            ?? 0
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCountCamel)
            ?? container.decodeIfPresent(Int.self, forKey: .voteCountSnake)
            ?? 0
        reviewName = try container.decodeIfPresent(String.self, forKey: .reviewNameCamel)
            ?? container.decodeIfPresent(String.self, forKey: .reviewNameSnake)
        reviewContent = try container.decodeIfPresent(String.self, forKey: .reviewContentCamel)
            ?? container.decodeIfPresent(String.self, forKey: .reviewContentSnake)
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
struct SearchResponse: Decodable {
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
