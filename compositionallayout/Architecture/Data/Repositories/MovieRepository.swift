//
//  MovieRepository.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Combine
import Foundation

public class MovieRepository: MovieRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    public init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    public func fetchMovies(category: MovieCategory, page: Int) -> AnyPublisher<[Movie], NetworkError> {
        let parameters = ["page": page]
        let interceptors: [RequestInterceptorProtocol] = [
            DefaultHeadersInterceptor(),
            APIKeyInterceptor()
        ]

        return networkService.request(
            endpoint: "/movie/\(category.rawValue)",
            method: .GET,
            parameters: parameters,
            interceptors: interceptors
        )
        .map { (response: MovieResponseDTO) in
            print("📦 [REPOSITORY] Received \(response.results.count) movies from API")
            print("📦 [REPOSITORY] First movie DTO: \(response.results.first?.title ?? "Unknown") - Poster: \(response.results.first?.posterPath ?? "nil")")

            let movies = response.results.map { dto in
                print("🔄 [REPOSITORY] Transforming DTO -> Entity: \(dto.title ?? "Unknown") (ID: \(dto.id))")
                print("🖼️ [REPOSITORY] DTO Poster path: \(dto.posterPath ?? "nil")")

                let movie = self.mapDTOToEntity(dto)
                print("✅ [REPOSITORY] Entity created: \(movie.title) - Poster: \(movie.posterPath ?? "nil")")
                return movie
            }

            print("🎯 [REPOSITORY] Successfully transformed \(movies.count) movies")
            return movies
        }
        .eraseToAnyPublisher()
    }

    public func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], NetworkError> {
        let parameters = [
            "query": query,
            "page": page
        ] as [String : Any]
        let interceptors: [RequestInterceptorProtocol] = [
            DefaultHeadersInterceptor(),
            APIKeyInterceptor()
        ]

        return networkService.request(
            endpoint: "/search/movie",
            method: .GET,
            parameters: parameters,
            interceptors: interceptors
        )
        .map { (response: MovieResponseDTO) in
            print("🔍 [REPOSITORY] Search received \(response.results.count) movies")
            print("🔍 [REPOSITORY] First search result: \(response.results.first?.title ?? "Unknown") - Poster: \(response.results.first?.posterPath ?? "nil")")

            let movies = response.results.map { dto in
                print("🔄 [REPOSITORY] Search transforming DTO -> Entity: \(dto.title ?? "Unknown") (ID: \(dto.id))")
                print("🖼️ [REPOSITORY] Search DTO Poster path: \(dto.posterPath ?? "nil")")

                let movie = self.mapDTOToEntity(dto)
                print("✅ [REPOSITORY] Search entity created: \(movie.title) - Poster: \(movie.posterPath ?? "nil")")
                return movie
            }

            print("🎯 [REPOSITORY] Search successfully transformed \(movies.count) movies")
            return movies
        }
        .eraseToAnyPublisher()
    }

    private func mapDTOToEntity(_ dto: MovieDTO) -> Movie {
        print("🔄 [REPOSITORY] Mapping DTO details - ID: \(dto.id), Title: \(dto.title ?? "nil")")
        print("🖼️ [REPOSITORY] DTO posterPath value: '\(dto.posterPath ?? "nil")'")

        let movie = Movie(
            id: dto.id,
            title: dto.title,
            posterPath: dto.posterPath,
            overview: dto.overview,
            releaseDate: dto.releaseDate,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount
        )

        print("✅ [REPOSITORY] Entity mapped - ID: \(movie.id), Title: \(movie.title), Poster: \(movie.posterPath ?? "nil")")
        return movie
    }
}
