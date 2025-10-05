//
//  MovieUseCaseProtocol.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Combine
import Foundation

public protocol MovieUseCaseProtocol {
    func execute(category: MovieCategory, page: Int) -> AnyPublisher<[Movie], NetworkError>
}

public protocol SearchMovieUseCaseProtocol {
    func execute(query: String, page: Int) -> AnyPublisher<[Movie], NetworkError>
}
