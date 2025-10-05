//
//  FetchMoviesUseCase.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Combine
import Foundation

public class FetchMoviesUseCase: MovieUseCaseProtocol {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(category: MovieCategory, page: Int = 1) -> AnyPublisher<[Movie], NetworkError> {
        return repository.fetchMovies(category: category, page: page)
    }
}
