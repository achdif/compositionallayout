//
//  APIManager.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

class APIManager {
    private let apiKey = "YOUR_API_KEY"
    private let baseURL = "https://api.themoviedb.org/3"

    func fetchMovies(endpoint: String, completion: @escaping ([MovieModel]) -> Void) {
        let urlString = "\(baseURL)\(endpoint)?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.results)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}
