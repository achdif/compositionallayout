//
//  NetworkService.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Combine
import Foundation

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: String,
                              method: HTTPMethod,
                              parameters: [String: Any]?,
                              interceptors: [RequestInterceptorProtocol]) -> AnyPublisher<T, NetworkError>
}

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func request<T: Decodable>(endpoint: String,
                                     method: HTTPMethod = .GET,
                                     parameters: [String: Any]? = nil,
                                     interceptors: [RequestInterceptorProtocol] = []) -> AnyPublisher<T, NetworkError> {

        // Build URL
        guard var urlComponents = URLComponents(string: NetworkConstants.baseURL + endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        // Add query parameters for GET requests
        if method == .GET, let parameters = parameters {
            var queryItems: [URLQueryItem] = []
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        print("🔗 [NETWORK] Requesting: \(method.rawValue) \(url)")

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add body for non-GET requests
        if method != .GET, let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                return Fail(error: NetworkError.decodingError(error)).eraseToAnyPublisher()
            }
        }

        // Apply interceptors
        for interceptor in interceptors {
            request = interceptor.intercept(request)
        }

        print("🚀 [NETWORK] Final request URL after interceptors: \(request.url?.absoluteString ?? "nil")")

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                print("📡 yohoho [NETWORK] Response: \(httpResponse.statusCode) - \(data.count) bytes")

                // Print raw JSON for debugging (first 500 chars)
                if let jsonString = String(data: data, encoding: .utf8) {
                    let preview = jsonString.prefix(500)
                    print("📄 yohoho [NETWORK] JSON Preview: \(preview)\(jsonString.count > 500 ? "..." : "")")
                }

                switch httpResponse.statusCode {
                case 200...299:
                    return data
                default:
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                }
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }

                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError(decodingError)
                }

                if let urlError = error as? URLError {
                    return NetworkError.networkError(urlError)
                }

                return NetworkError.unknown
            }
            .eraseToAnyPublisher()
    }
}
