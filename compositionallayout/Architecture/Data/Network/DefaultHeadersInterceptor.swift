//
//  DefaultHeadersInterceptor.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

public class DefaultHeadersInterceptor: RequestInterceptorProtocol {
    public init() {}

    public func intercept(_ request: URLRequest) -> URLRequest {
        var request = request

        // Add default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("compositionallayout/1.0", forHTTPHeaderField: "User-Agent")

        return request
    }
}
