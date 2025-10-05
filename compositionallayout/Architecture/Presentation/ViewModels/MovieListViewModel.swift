//
//  MovieListViewModel.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Combine
import Foundation

public class MovieListViewModel {

    // MARK: - Properties
    private let fetchMoviesUseCase: MovieUseCaseProtocol
    private let searchMoviesUseCase: SearchMovieUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published Properties
    @Published public var popularMovies: [Movie] = []
    @Published public var upcomingMovies: [Movie] = []
    @Published public var isLoading: Bool = false
    @Published public var error: NetworkError?
    @Published public var searchResults: [Movie] = []
    @Published public var isSearching: Bool = false

    // MARK: - Initialization
    public init(fetchMoviesUseCase: MovieUseCaseProtocol,
                searchMoviesUseCase: SearchMovieUseCaseProtocol) {
        self.fetchMoviesUseCase = fetchMoviesUseCase
        self.searchMoviesUseCase = searchMoviesUseCase
    }

    // MARK: - Public Methods
    public func fetchMovies() {
        isLoading = true
        error = nil

        let popularPublisher = fetchMoviesUseCase.execute(category: .popular, page: 1)
        let upcomingPublisher = fetchMoviesUseCase.execute(category: .upcoming, page: 1)

        Publishers.Zip(popularPublisher, upcomingPublisher)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] popularMovies, upcomingMovies in
                print("yohoho DEBUG: ViewModel received \(popularMovies.count) popular movies")
                print("yohoho DEBUG: First popular movie poster: \(popularMovies.first?.posterPath ?? "nil")")
                self?.popularMovies = popularMovies
                self?.upcomingMovies = upcomingMovies
            }
            .store(in: &cancellables)
    }

    public func searchMovies(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        error = nil

        searchMoviesUseCase.execute(query: query, page: 1)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &cancellables)
    }

    public func retry() {
        if isSearching {
            // Retry search if currently searching
            if let lastQuery = getLastSearchQuery() {
                searchMovies(query: lastQuery)
            }
        } else {
            // Retry fetching movies
            fetchMovies()
        }
    }

    public func clearSearch() {
        searchResults = []
        isSearching = false
    }

    // MARK: - Private Methods
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            self.error = networkError
        } else {
            self.error = NetworkError.unknown
        }
    }

    private func getLastSearchQuery() -> String? {
        // In a more complex implementation, you'd store the last search query
        // For now, return a placeholder
        return nil
    }
}
