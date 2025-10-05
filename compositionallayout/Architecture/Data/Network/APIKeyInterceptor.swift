//
//  APIKeyInterceptor.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

public class APIKeyInterceptor: RequestInterceptorProtocol {
    public init() {}

    public func intercept(_ request: URLRequest) -> URLRequest {
        var request = request

        guard let url = request.url else {
            print("❌ [INTERCEPTOR] No URL found in request")
            return request
        }

        // Add API key as query parameter
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

        guard var queryItems = urlComponents?.queryItems else {
            print("❌ [INTERCEPTOR] Failed to get query items from URL: \(url)")
            return request
        }

        print("🔑 [INTERCEPTOR] Adding API key to URL: \(url)")
        queryItems.append(URLQueryItem(name: "api_key", value: NetworkConstants.apiKey))
        queryItems.append(URLQueryItem(name: "language", value: "en-US"))
        urlComponents?.queryItems = queryItems

        guard let finalURL = urlComponents?.url else {
            print("❌ [INTERCEPTOR] Failed to construct final URL with API key")
            return request
        }

        print("✅ [INTERCEPTOR] Final URL: \(finalURL)")
        request.url = finalURL
        return request
    }
}
