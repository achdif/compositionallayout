//
//  MovieCategory.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

public enum MovieCategory: String {
    case popular = "popular"
    case upcoming = "upcoming"
    case topRated = "top_rated"
    case nowPlaying = "now_playing"

    public var displayName: String {
        switch self {
        case .popular:
            return "Popular"
        case .upcoming:
            return "Upcoming"
        case .topRated:
            return "Top Rated"
        case .nowPlaying:
            return "Now Playing"
        }
    }
}
