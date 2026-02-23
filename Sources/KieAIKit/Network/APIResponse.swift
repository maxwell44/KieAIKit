//
//  APIResponse.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Kie.ai API response wrapper.
///
/// All Kie.ai API responses are wrapped in this structure:
/// ```json
/// {
///   "code": 200,
///   "msg": "success",
///   "data": { ... }
/// }
/// ```
public struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {

    /// The response code (200 for success).
    public let code: Int

    /// The response message.
    public let msg: String

    /// The response data.
    public let data: T?

    /// True if the request was successful (code == 200).
    public var isSuccess: Bool {
        return code == 200
    }

    private enum CodingKeys: String, CodingKey {
        case code
        case msg
        case data
    }

    public init(code: Int, msg: String, data: T? = nil) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    /// Validates the response and returns the data.
    /// - Returns: The unwrapped data
    /// - Throws: APIError if the response indicates an error
    public func validateAndGet() throws -> T {
        guard isSuccess else {
            throw APIError.serverError(msg)
        }

        guard let data = data else {
            throw APIError.decodingFailed(NSError(domain: "KieAIKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response data is nil"]))
        }

        return data
    }
}

/// API response for task creation.
public struct TaskCreationResponse: Codable, Sendable {
    public let taskId: String

    private enum CodingKeys: String, CodingKey {
        case taskId  // API uses camelCase "taskId"
    }
}
