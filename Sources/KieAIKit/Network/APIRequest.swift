//
//  APIRequest.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Internal representation of an API request.
struct APIRequest<Body: Encodable> {

    /// The HTTP method to use.
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    /// The path to append to the base URL.
    let path: String

    /// The HTTP method.
    let method: Method

    /// The request body (optional).
    let body: Body?

    /// Query parameters to append to the URL.
    let queryItems: [URLQueryItem]

    /// Additional headers to include.
    let headers: [String: String]

    /// Creates a new API request.
    init(
        path: String,
        method: Method = .post,
        body: Body? = nil,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:]
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.queryItems = queryItems
        self.headers = headers
    }

    /// Converts the request to a URLRequest.
    /// - Parameters:
    ///   - baseURL: The base URL for the API
    ///   - apiKey: The API key for authentication
    /// - Returns: A URLRequest, or nil if the URL is invalid
    /// - Throws: An error if encoding fails
    func makeURLRequest(baseURL: String, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL(baseURL)
        }

        var components = URLComponents(url: url.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let finalURL = components?.url else {
            throw APIError.invalidURL(path)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.outputFormatting = .withoutEscapingSlashes
            request.httpBody = try encoder.encode(body)
        }

        return request
    }
}

/// Convenience extension for requests without a body.
extension APIRequest where Body == EmptyRequestBody {
    init(
        path: String,
        method: Method = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:]
    ) {
        self.init(path: path, method: method, body: nil, queryItems: queryItems, headers: headers)
    }
}

/// Empty type for requests without a body.
struct EmptyRequestBody: Encodable {}
