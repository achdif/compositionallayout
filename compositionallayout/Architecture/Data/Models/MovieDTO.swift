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
        case posterPath = "poster_path"
        case overview
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount)

        print("🔄 [DTO] Decoded MovieDTO - ID: \(id), Title: \(title ?? "nil")")
        print("🖼️ [DTO] Poster path: \(posterPath ?? "nil")")
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
