//
//  APIClient.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Internal HTTP client for making API requests.
final class APIClient {

    /// The configuration for the client.
    let configuration: Configuration

    /// The URLSession for making network requests.
    let session: URLSession

    /// Creates a new API client.
    /// - Parameter configuration: The configuration to use
    init(configuration: Configuration) {
        self.configuration = configuration

        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.timeoutIntervalForRequest = configuration.timeout
        urlSessionConfig.timeoutIntervalForResource = configuration.timeout
        self.session = URLSession(configuration: urlSessionConfig)
    }

    /// Performs a request and decodes the response.
    ///
    /// - Parameters:
    ///   - request: The API request to perform
    ///   - responseType: The type to decode the response as
    /// - Returns: The decoded response
    /// - Throws: An APIError if the request fails
    func perform<RequestBody: Encodable, Response: Decodable>(
        _ request: APIRequest<RequestBody>,
        as responseType: Response.Type
    ) async throws -> Response {
        let urlRequest = try request.makeURLRequest(
            baseURL: configuration.baseURL,
            apiKey: configuration.apiKey
        )

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(URLError(.badServerResponse))
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.from(response: httpResponse, data: data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    /// Performs a request without decoding the response.
    ///
    /// - Parameter request: The API request to perform
    /// - Throws: An APIError if the request fails
    func perform<RequestBody: Encodable>(
        _ request: APIRequest<RequestBody>
    ) async throws {
        let urlRequest = try request.makeURLRequest(
            baseURL: configuration.baseURL,
            apiKey: configuration.apiKey
        )

        let (_, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(URLError(.badServerResponse))
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.from(response: httpResponse, data: nil)
        }
    }
}
