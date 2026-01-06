//
//  VideoGenerationResult.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Result of a successful video generation.
public struct VideoGenerationResult: Codable, Sendable {

    /// The task ID for this generation.
    public let taskId: String

    /// URL to the generated video.
    public let videoURL: URL

    /// URL to a thumbnail/preview image.
    public let thumbnailURL: URL?

    /// The model used for generation.
    public let model: String

    /// The prompt used for generation.
    public let prompt: String

    /// Duration of the video in seconds.
    public let duration: Double?

    /// Resolution (width x height).
    public let resolution: String?

    /// FPS (frames per second) of the video.
    public let fps: Int?

    /// File size in bytes.
    public let fileSize: Int?

    /// Seed used for generation.
    public let seed: Int?

    /// Additional metadata.
    public let metadata: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case videoURL = "video_url"
        case thumbnailURL = "thumbnail_url"
        case model
        case prompt
        case duration
        case resolution
        case fps
        case fileSize = "file_size"
        case seed
        case metadata
    }

    public init(
        taskId: String,
        videoURL: URL,
        thumbnailURL: URL? = nil,
        model: String,
        prompt: String,
        duration: Double? = nil,
        resolution: String? = nil,
        fps: Int? = nil,
        fileSize: Int? = nil,
        seed: Int? = nil,
        metadata: [String: String]? = nil
    ) {
        self.taskId = taskId
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.model = model
        self.prompt = prompt
        self.duration = duration
        self.resolution = resolution
        self.fps = fps
        self.fileSize = fileSize
        self.seed = seed
        self.metadata = metadata
    }
}
