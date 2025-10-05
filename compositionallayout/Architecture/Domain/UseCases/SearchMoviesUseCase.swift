//
//  SearchMoviesUseCase.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Combine
import Foundation

public class SearchMoviesUseCase: SearchMovieUseCaseProtocol {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(query: String, page: Int = 1) -> AnyPublisher<[Movie], NetworkError> {
        return repository.searchMovies(query: query, page: page)
    }
}
