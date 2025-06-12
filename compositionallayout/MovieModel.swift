//
//  MovieModel.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

struct MovieModel: Decodable, Hashable {
    let id: Int?
    let title: String?
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
    }
}

struct MovieResponse: Decodable {
    let results: [MovieModel]
}
