//
//  MovieDTO.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

public struct MovieDTO: Decodable, Hashable {
    public let id: Int
    public let title: String
    public let posterPath: String?
    public let overview: String?
    public let releaseDate: String?
    public let voteAverage: Double?
    public let voteCount: Int?

    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath
        case overview
        case releaseDate
        case voteAverage
        case voteCount
    }
}

public struct MovieResponseDTO: Decodable {
    public let results: [MovieDTO]
    public let page: Int?
    public let totalPages: Int?
    public let totalResults: Int?

    public enum CodingKeys: String, CodingKey {
        case results = "results"
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
