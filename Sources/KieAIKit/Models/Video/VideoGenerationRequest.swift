//
//  VideoGenerationRequest.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Request parameters for video generation.
public struct VideoGenerationRequest: Codable, Sendable {

    /// The text prompt describing the video to generate.
    public let prompt: String

    /// Negative prompt - what to avoid in the generated video.
    public let negativePrompt: String?

    /// Duration of the video in seconds (typically 2-10).
    public let duration: Int?

    /// Aspect ratio of the video.
    public let aspectRatio: AspectRatio?

    /// FPS (frames per second) for the video.
    public let fps: Int?

    /// Seed for reproducible generation.
    public let seed: Int?

    /// URL to an initial image for image-to-video generation.
    public let initImageURL: URL?

    /// Additional model-specific parameters.
    public let parameters: [String: AnyCodable]?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case negativePrompt = "negative_prompt"
        case duration
        case aspectRatio = "aspect_ratio"
        case fps
        case seed
        case initImageURL = "init_image_url"
        case parameters
    }

    public init(
        prompt: String,
        negativePrompt: String? = nil,
        duration: Int? = nil,
        aspectRatio: AspectRatio? = nil,
        fps: Int? = nil,
        seed: Int? = nil,
        initImageURL: URL? = nil,
        parameters: [String: Any]? = nil
    ) {
        self.prompt = prompt
        self.negativePrompt = negativePrompt
        self.duration = duration
        self.aspectRatio = aspectRatio
        self.fps = fps
        self.seed = seed
        self.initImageURL = initImageURL

        if let parameters = parameters {
            self.parameters = parameters.mapValues { AnyCodable($0) }
        } else {
            self.parameters = nil
        }
    }

    /// Common aspect ratios for video generation.
    public enum AspectRatio: String, Codable, Sendable {
        case square = "1:1"
        case portrait = "9:16"
        case landscape = "16:9"
        case cinematic = "21:9"
    }

    /// Creates a request with common presets.
    public static func with(
        prompt: String,
        duration: Int = 5,
        aspectRatio: AspectRatio = .landscape
    ) -> VideoGenerationRequest {
        return VideoGenerationRequest(
            prompt: prompt,
            duration: duration,
            aspectRatio: aspectRatio
        )
    }

    /// Creates an image-to-video request.
    public static func imageToVideo(
        prompt: String,
        initImageURL: URL,
        duration: Int = 5
    ) -> VideoGenerationRequest {
        return VideoGenerationRequest(
            prompt: prompt,
            duration: duration,
            initImageURL: initImageURL
        )
    }
}
