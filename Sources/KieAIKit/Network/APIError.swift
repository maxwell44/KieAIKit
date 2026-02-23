//
//  APIError.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Errors that can occur when interacting with the Kie.ai API.
public enum APIError: Error, LocalizedError, CustomStringConvertible {

    /// The provided URL is invalid.
    case invalidURL(String)

    /// The HTTP request failed with a specific status code.
    case requestFailed(Int, Data?)

    /// Failed to decode the API response.
    case decodingFailed(Error)

    /// The task on the server failed.
    case taskFailed(String)

    /// The task timed out during polling.
    case timeout

    /// The API key is missing or invalid.
    case unauthorized

    /// The request body was invalid.
    case badRequest(String)

    /// The server encountered an error.
    case serverError(String)

    /// The requested resource was not found.
    case notFound

    /// The rate limit was exceeded.
    case rateLimited

    /// The requested result type does not match the task content type.
    case resultTypeMismatch(expected: String, actual: String?)

    /// Network connectivity issue.
    case networkError(Error)

    /// Unknown error.
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .requestFailed(let code, let data):
            if let data = data, let message = String(data: data, encoding: .utf8) {
                return "Request failed with status code \(code): \(message)"
            }
            return "Request failed with status code \(code)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .taskFailed(let message):
            return "Task failed: \(message)"
        case .timeout:
            return "Request timed out"
        case .unauthorized:
            return "Unauthorized: Please check your API key"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Rate limit exceeded"
        case .resultTypeMismatch(let expected, let actual):
            if let actual = actual {
                return "Result type mismatch: expected \(expected), got \(actual)"
            }
            return "Result type mismatch: expected \(expected), but task content type is missing"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }

    public var description: String {
        return errorDescription ?? "Unknown error"
    }

    /// Creates an APIError from a URLSession error.
    static func from(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        return .networkError(error)
    }

    /// Creates an APIError from an HTTPURLResponse.
    static func from(response: HTTPURLResponse, data: Data?) -> APIError {
        switch response.statusCode {
        case 400:
            return .badRequest(data.flatMap { String(data: $0, encoding: .utf8) } ?? "Invalid request")
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 429:
            return .rateLimited
        case 500...599:
            return .serverError(data.flatMap { String(data: $0, encoding: .utf8) } ?? "Internal server error")
        default:
            return .requestFailed(response.statusCode, data)
        }
    }
}
