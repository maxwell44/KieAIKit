//
//  TaskInfo.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Information about an asynchronous task.
public struct TaskInfo: Codable, Sendable {

    /// The unique identifier for the task.
    public let id: String

    /// The current status of the task.
    public let status: TaskStatus

    /// The type of content being generated (image, video, audio).
    public let contentType: ContentType?

    /// The model being used for generation.
    public let model: String?

    /// The timestamp when the task was created.
    public let createdAt: Date?

    /// The timestamp when the task started processing.
    public let startedAt: Date?

    /// The timestamp when the task completed.
    public let completedAt: Date?

    /// Error message if the task failed.
    public let errorMessage: String?

    /// Progress percentage (0-100) if available.
    public let progress: Int?

    /// URL to the result when the task is complete.
    public let resultURL: URL?

    /// Additional metadata.
    public let metadata: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case id = "taskId"     // API uses "taskId"
        case status = "state"  // API uses "state" not "status"
        case contentType = "content_type"
        case model
        case createdAt  // Will decode "createTime" manually
        case startedAt = "started_at"
        case completedAt  // Will decode "completeTime" manually
        case errorMessage  // Will decode "failMsg" manually
        case failCode
        case failMsg
        case resultJson  // API uses "resultJson" for result
        case progress
        case resultURL = "result_url"
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required fields
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(TaskStatus.self, forKey: .status)

        // Optional fields
        contentType = try container.decodeIfPresent(ContentType.self, forKey: .contentType)
        model = try container.decodeIfPresent(String.self, forKey: .model)

        // Handle timestamp fields (milliseconds since epoch)
        if let createTimeTimestamp = try? container.decode(Int64.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: TimeInterval(createTimeTimestamp) / 1000.0)
        } else {
            createdAt = nil
        }

        if let completeTimeTimestamp = try? container.decodeIfPresent(Int64.self, forKey: .completedAt) {
            completedAt = Date(timeIntervalSince1970: TimeInterval(completeTimeTimestamp) / 1000.0)
        } else {
            completedAt = nil
        }

        startedAt = try container.decodeIfPresent(Date.self, forKey: .startedAt)

        // Error message can be from "failMsg" or "errorMessage"
        let failMsg = try container.decodeIfPresent(String.self, forKey: .failMsg)
        let errorMsg = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        errorMessage = failMsg ?? errorMsg

        progress = try container.decodeIfPresent(Int.self, forKey: .progress)

        // Result URL - try to get from "resultJson" field
        if let resultJson = try? container.decode(String.self, forKey: .resultJson),
           !resultJson.isEmpty,
           let data = resultJson.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let resultUrls = json["resultUrls"] as? [String],
           let urlString = resultUrls.first,
           let url = URL(string: urlString) {
            resultURL = url
        } else {
            resultURL = try container.decodeIfPresent(URL.self, forKey: .resultURL)
        }

        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(contentType, forKey: .contentType)
        try container.encodeIfPresent(model, forKey: .model)
        try container.encodeIfPresent(errorMessage, forKey: .errorMessage)
        try container.encodeIfPresent(progress, forKey: .progress)
        try container.encodeIfPresent(resultURL, forKey: .resultURL)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }

    public init(
        id: String,
        status: TaskStatus,
        contentType: ContentType? = nil,
        model: String? = nil,
        createdAt: Date? = nil,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        errorMessage: String? = nil,
        progress: Int? = nil,
        resultURL: URL? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.status = status
        self.contentType = contentType
        self.model = model
        self.createdAt = createdAt
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.errorMessage = errorMessage
        self.progress = progress
        self.resultURL = resultURL
        self.metadata = metadata
    }

    /// Validates that the task info is valid for polling.
    /// - Throws: APIError if the task info is invalid
    public func validate() throws {
        guard !id.isEmpty else {
            throw APIError.badRequest("Invalid task ID: task ID is empty")
        }

        // Check if the task immediately failed
        if status == .failed, let message = errorMessage {
            throw APIError.taskFailed(message)
        }
    }
}

/// The type of content being generated.
public enum ContentType: String, Codable, Sendable {
    case image
    case video
    case audio
}
