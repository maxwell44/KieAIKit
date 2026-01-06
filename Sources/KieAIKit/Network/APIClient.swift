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

    /// Performs a request and decodes the response with Kie.ai wrapper.
    ///
    /// This method automatically unwraps the Kie.ai API response format:
    /// ```json
    /// {
    ///   "code": 200,
    ///   "msg": "success",
    ///   "data": { ... }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - request: The API request to perform
    ///   - responseType: The type to decode the data field as
    /// - Returns: The unwrapped data from the response
    /// - Throws: An APIError if the request fails or returns an error code
    func performAndUnwrap<RequestBody: Encodable, Response: Decodable>(
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

        // Check for HTTP-level errors first
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.from(response: httpResponse, data: data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // Debug: Print raw response in DEBUG mode
            #if DEBUG
            if let rawString = String(data: data, encoding: .utf8) {
                print("🧾 KieAIKit Raw Response:")
                print(rawString)
            }
            #endif

            // Decode the wrapped response
            let wrappedResponse = try decoder.decode(APIResponse<Response>.self, from: data)

            // Validate and unwrap
            return try wrappedResponse.validateAndGet()
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
