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
    
    func fetchMovies(endpoint: String, completion: @escaping ([Movie]) -> Void) {
        let urlString = "\(baseURL)\(endpoint)?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode([String: [Movie]].self, from: data)
                    DispatchQueue.main.async {
                        completion(response["results"] ?? [])
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}
