import Foundation
import SwiftData

final class RealmManager: ObservableObject {
    static let shared = RealmManager()

    let modelContainer: ModelContainer
    private let modelContext: ModelContext

    private init() {
        do {
            modelContainer = try ModelContainer(for: WatchRecord.self, CachedMovie.self)
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Error initializing SwiftData: \(error)")
        }
    }

    func getWatchStatus(for movieId: Int) -> UserWatchStatus.WatchStatus? {
        fetchWatchRecord(for: movieId)?.watchStatus
    }

    func updateWatchStatus(for movieId: Int, status: UserWatchStatus.WatchStatus) {
        if let existingStatus = fetchWatchRecord(for: movieId) {
            existingStatus.status = status.rawValue
            existingStatus.dateAdded = Date()
        } else {
            modelContext.insert(WatchRecord(movieId: movieId, status: status))
        }

        saveChanges()
    }

    func removeWatchStatus(for movieId: Int) {
        guard let statusToDelete = fetchWatchRecord(for: movieId) else { return }
        modelContext.delete(statusToDelete)
        saveChanges()
    }

    func getMoviesWithStatus(_ status: UserWatchStatus.WatchStatus) -> [Int] {
        let statusRawValue = status.rawValue
        var descriptor = FetchDescriptor<WatchRecord>(
            predicate: #Predicate { $0.status == statusRawValue },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        descriptor.includePendingChanges = true

        do {
            return try modelContext.fetch(descriptor).map(\.movieId)
        } catch {
            print("Error fetching watch status: \(error)")
            return []
        }
    }

    func saveMovie(_ movie: Movie) {
        if let cachedMovie = fetchCachedMovie(for: movie.id) {
            cachedMovie.update(from: movie)
        } else {
            modelContext.insert(CachedMovie(movie: movie))
        }

        saveChanges()
    }

    func saveMovieDetail(_ response: TVShowDetailResponse) {
        if let cachedMovie = fetchCachedMovie(for: response.id) {
            cachedMovie.update(from: response)
        } else {
            modelContext.insert(CachedMovie(from: response))
        }

        saveChanges()
    }

    func getMovie(for movieId: Int) -> Movie? {
        fetchCachedMovie(for: movieId)?.toMovie()
    }

    private func fetchWatchRecord(for movieId: Int) -> WatchRecord? {
        var descriptor = FetchDescriptor<WatchRecord>(
            predicate: #Predicate { $0.movieId == movieId }
        )
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true

        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Error fetching watch record: \(error)")
            return nil
        }
    }

    private func fetchCachedMovie(for movieId: Int) -> CachedMovie? {
        var descriptor = FetchDescriptor<CachedMovie>(
            predicate: #Predicate { $0.id == movieId }
        )
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true

        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Error fetching cached movie: \(error)")
            return nil
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving SwiftData changes: \(error)")
        }
    }
}
