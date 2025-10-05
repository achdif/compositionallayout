//
//  NetworkError.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case serverError(statusCode: Int)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknown:
            return "Unknown error occurred"
        }
    }

    public var title: String {
        switch self {
        case .invalidURL, .invalidResponse, .decodingError, .unknown:
            return "Data Error"
        case .networkError:
            return "Connection Error"
        case .serverError:
            return "Server Error"
        }
    }

    public var imageName: String {
        switch self {
        case .invalidURL, .invalidResponse, .decodingError, .unknown:
            return "error_icon"
        case .networkError:
            return "network_error_icon"
        case .serverError:
            return "server_error_icon"
        }
    }
}
