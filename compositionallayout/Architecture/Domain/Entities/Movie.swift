//
//  Movie.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

public struct Movie: Equatable, Identifiable {
    public let id: Int
    public let title: String
    public let posterPath: String?
    public let overview: String?
    public let releaseDate: String?
    public let voteAverage: Double?
    public let voteCount: Int?

    public init(id: Int,
                title: String,
                posterPath: String?,
                overview: String?,
                releaseDate: String?,
                voteAverage: Double?,
                voteCount: Int?) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.overview = overview
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
}

// MARK: - Hashable
extension Movie: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
