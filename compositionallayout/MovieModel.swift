//
//  MovieModel.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let title: String
    let posterPath: String
}
