//
//  ImageGenerationResult.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Result of a successful image generation.
public struct ImageGenerationResult: Codable, Sendable {

    /// The task ID for this generation.
    public let taskId: String

    /// URLs to the generated images.
    public let imageUrls: [URL]

    /// The model used for generation.
    public let model: String

    /// The prompt used for generation.
    public let prompt: String

    /// Width of the generated images.
    public let width: Int?

    /// Height of the generated images.
    public let height: Int?

    /// Seed used for generation (for reproducibility).
    public let seed: Int?

    /// Additional metadata.
    public let metadata: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case imageUrls = "image_urls"
        case model
        case prompt
        case width
        case height
        case seed
        case metadata
    }

    public init(
        taskId: String,
        imageUrls: [URL],
        model: String,
        prompt: String,
        width: Int? = nil,
        height: Int? = nil,
        seed: Int? = nil,
        metadata: [String: String]? = nil
    ) {
        self.taskId = taskId
        self.imageUrls = imageUrls
        self.model = model
        self.prompt = prompt
        self.width = width
        self.height = height
        self.seed = seed
        self.metadata = metadata
    }

    /// Returns the primary image URL (first in the array).
    public var primaryImageURL: URL? {
        return imageUrls.first
    }
}
