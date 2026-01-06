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
        case id
        case status
        case contentType = "content_type"
        case model
        case createdAt = "created_at"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case errorMessage = "error_message"
        case progress
        case resultURL = "result_url"
        case metadata
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
