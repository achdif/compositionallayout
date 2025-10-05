//
//  RequestInterceptorProtocol.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import Foundation

public protocol RequestInterceptorProtocol {
    func intercept(_ request: URLRequest) -> URLRequest
}
