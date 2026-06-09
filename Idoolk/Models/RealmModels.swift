import Foundation
import SwiftData

enum UserWatchStatus {
    enum WatchStatus: String, Codable, CaseIterable, Identifiable {
        case wantToWatch = "想看"
        case watching = "在看"
        case watched = "已看"

        var id: String { rawValue }
    }
}

@Model
final class WatchRecord {
    @Attribute(.unique) var movieId: Int
    var status: String
    var dateAdded: Date

    init(movieId: Int, status: UserWatchStatus.WatchStatus) {
        self.movieId = movieId
        self.status = status.rawValue
        self.dateAdded = Date()
    }

    var watchStatus: UserWatchStatus.WatchStatus? {
        UserWatchStatus.WatchStatus(rawValue: status)
    }
}

@Model
final class CachedMovie {
    @Attribute(.unique) var id: Int
    var adult: Bool
    var backdropPath: String?
    var genreIdsData: Data
    var originCountryData: Data?
    var originalLanguage: String
    var originalName: String
    var overview: String
    var popularity: Double
    var posterPath: String?
    var firstAirDate: String
    var name: String
    var voteAverage: Double
    var voteCount: Int
    var numberOfEpisodes: Int
    var numberOfSeasons: Int
    var status: String
    var type: String
    var updatedAt: Date

    init(movie: Movie, numberOfEpisodes: Int = 0, numberOfSeasons: Int = 0, status: String = "", type: String = "") {
        self.id = movie.id
        self.adult = movie.adult
        self.backdropPath = movie.backdropPath
        self.genreIdsData = Self.encode(movie.genreIds)
        self.originCountryData = Self.encode(movie.originCountry)
        self.originalLanguage = movie.originalLanguage
        self.originalName = movie.originalName
        self.overview = movie.overview
        self.popularity = movie.popularity
        self.posterPath = movie.posterPath
        self.firstAirDate = movie.firstAirDate
        self.name = movie.name
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.numberOfEpisodes = numberOfEpisodes
        self.numberOfSeasons = numberOfSeasons
        self.status = status
        self.type = type
        self.updatedAt = Date()
    }

    convenience init(from response: TVShowDetailResponse) {
        let movie = Movie(
            adult: response.adult,
            backdropPath: response.backdropPath,
            genreIds: response.genres.map(\.id),
            id: response.id,
            originCountry: response.originCountry,
            originalLanguage: response.originalLanguage,
            originalName: response.originalName,
            overview: response.overview,
            popularity: response.popularity,
            posterPath: response.posterPath,
            firstAirDate: response.firstAirDate,
            name: response.name,
            voteAverage: response.voteAverage,
            voteCount: response.voteCount
        )

        self.init(
            movie: movie,
            numberOfEpisodes: response.numberOfEpisodes,
            numberOfSeasons: response.numberOfSeasons,
            status: response.status,
            type: response.type
        )
    }

    func update(from movie: Movie, numberOfEpisodes: Int = 0, numberOfSeasons: Int = 0, status: String = "", type: String = "") {
        self.adult = movie.adult
        self.backdropPath = movie.backdropPath
        self.genreIdsData = Self.encode(movie.genreIds)
        self.originCountryData = Self.encode(movie.originCountry)
        self.originalLanguage = movie.originalLanguage
        self.originalName = movie.originalName
        self.overview = movie.overview
        self.popularity = movie.popularity
        self.posterPath = movie.posterPath
        self.firstAirDate = movie.firstAirDate
        self.name = movie.name
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.numberOfEpisodes = numberOfEpisodes
        self.numberOfSeasons = numberOfSeasons
        self.status = status
        self.type = type
        self.updatedAt = Date()
    }

    func update(from response: TVShowDetailResponse) {
        let movie = Movie(
            adult: response.adult,
            backdropPath: response.backdropPath,
            genreIds: response.genres.map(\.id),
            id: response.id,
            originCountry: response.originCountry,
            originalLanguage: response.originalLanguage,
            originalName: response.originalName,
            overview: response.overview,
            popularity: response.popularity,
            posterPath: response.posterPath,
            firstAirDate: response.firstAirDate,
            name: response.name,
            voteAverage: response.voteAverage,
            voteCount: response.voteCount
        )

        update(
            from: movie,
            numberOfEpisodes: response.numberOfEpisodes,
            numberOfSeasons: response.numberOfSeasons,
            status: response.status,
            type: response.type
        )
    }

    func toMovie() -> Movie {
        Movie(
            adult: adult,
            backdropPath: backdropPath,
            genreIds: Self.decode([Int].self, from: genreIdsData) ?? [],
            id: id,
            originCountry: Self.decode([String].self, from: originCountryData),
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

    private static func encode<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder().encode(value)) ?? Data()
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data, !data.isEmpty else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
