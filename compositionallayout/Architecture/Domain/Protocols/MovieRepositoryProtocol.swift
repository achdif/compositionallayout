//
//  MovieRepositoryProtocol.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Combine
import Foundation

public protocol MovieRepositoryProtocol {
    func fetchMovies(category: MovieCategory, page: Int) -> AnyPublisher<[Movie], NetworkError>
    func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], NetworkError>
}
