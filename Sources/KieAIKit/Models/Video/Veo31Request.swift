//
//  Veo31Request.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//  Veo 3.1 Video Generation Request Models
//

import Foundation

/// Veo 3.1 video generation request.
///
/// Supports text-to-video, image-to-video, and reference-based generation modes.
public struct Veo31Request: Codable, Sendable {

    /// Text prompt describing the desired video content.
    public let prompt: String

    /// Array of image URLs for image-to-video modes.
    /// - 1 image: Generate video based on the provided image
    /// - 2 images: First image as first frame, second as last frame
    /// - 1-3 images for REFERENCE_2_VIDEO mode
    public let imageUrls: [URL]?

    /// Model variant to use.
    /// - veo3: Veo 3.1 Quality (highest fidelity)
    /// - veo3_fast: Veo 3.1 Fast (cost-efficient)
    public let model: VeoModel

    /// Video generation mode.
    public let mode: GenerationMode?

    /// Video aspect ratio.
    /// - 16:9: Landscape (supports 1080P HD)
    /// - 9:16: Portrait (vertical video)
    /// - Auto: Match based on uploaded image
    public let aspectRatio: AspectRatio?

    /// Random seed for reproducible generation (10000-99999).
    public let seed: Int?

    /// Callback URL for completion notification.
    public let callbackUrl: URL?

    /// Enable prompt translation to English (default: true).
    public let enableTranslation: Bool?

    /// Watermark text to add to the video.
    public let watermark: String?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case imageUrls = "imageUrls"
        case model
        case mode
        case aspectRatio = "aspectRatio"
        case seed
        case callbackUrl = "callbackUrl"
        case enableTranslation = "enableTranslation"
        case watermark
    }

    public init(
        prompt: String,
        imageUrls: [URL]? = nil,
        model: VeoModel = .veo3_fast,
        mode: GenerationMode? = nil,
        aspectRatio: AspectRatio? = nil,
        seed: Int? = nil,
        callbackUrl: URL? = nil,
        enableTranslation: Bool? = nil,
        watermark: String? = nil
    ) {
        self.prompt = prompt
        self.imageUrls = imageUrls
        self.model = model
        self.mode = mode
        self.aspectRatio = aspectRatio
        self.seed = seed
        self.callbackUrl = callbackUrl
        self.enableTranslation = enableTranslation
        self.watermark = watermark
    }

    /// Veo 3.1 model variants.
    public enum VeoModel: String, Codable, Sendable {
        /// Veo 3.1 Quality - Highest fidelity, supports both text-to-video and image-to-video
        case veo3 = "veo3"
        /// Veo 3.1 Fast - Cost-efficient variant
        case veo3_fast = "veo3_fast"
    }

    /// Video generation modes.
    public enum GenerationMode: String, Codable, Sendable {
        /// Text-to-video using only text prompts
        case text2Video = "TEXT_2_VIDEO"
        /// Image-to-video with first and last frames
        case firstAndLastFrames2Video = "FIRST_AND_LAST_FRAMES_2_VIDEO"
        /// Reference-to-video based on material images (only veo3_fast, 16:9)
        case reference2Video = "REFERENCE_2_VIDEO"
    }

    /// Video aspect ratios.
    public enum AspectRatio: String, Codable, Sendable {
        /// Landscape format (supports 1080P HD)
        case landscape = "16:9"
        /// Portrait format for mobile
        case portrait = "9:16"
        /// Auto-detect from image
        case auto = "Auto"
    }

    // MARK: - Convenience Factory Methods

    /// Creates a text-to-video request.
    public static func textToVideo(
        prompt: String,
        model: VeoModel = .veo3_fast,
        aspectRatio: AspectRatio = .landscape,
        duration: Int? = nil
    ) -> Veo31Request {
        return Veo31Request(
            prompt: prompt,
            imageUrls: nil,
            model: model,
            mode: .text2Video,
            aspectRatio: aspectRatio
        )
    }

    /// Creates an image-to-video request with a single image.
    public static func imageToVideo(
        prompt: String,
        imageUrl: URL,
        model: VeoModel = .veo3_fast,
        aspectRatio: AspectRatio = .auto
    ) -> Veo31Request {
        return Veo31Request(
            prompt: prompt,
            imageUrls: [imageUrl],
            model: model,
            mode: .firstAndLastFrames2Video,
            aspectRatio: aspectRatio
        )
    }

    /// Creates an image-to-video request with first and last frames.
    public static func firstAndLastFramesToVideo(
        prompt: String,
        firstFrameUrl: URL,
        lastFrameUrl: URL,
        model: VeoModel = .veo3_fast,
        aspectRatio: AspectRatio = .landscape
    ) -> Veo31Request {
        return Veo31Request(
            prompt: prompt,
            imageUrls: [firstFrameUrl, lastFrameUrl],
            model: model,
            mode: .firstAndLastFrames2Video,
            aspectRatio: aspectRatio
        )
    }

    /// Creates a reference-based video generation request (1-3 images).
    public static func referenceToVideo(
        prompt: String,
        imageUrls: [URL],
        aspectRatio: AspectRatio = .landscape
    ) -> Veo31Request {
        precondition(imageUrls.count >= 1 && imageUrls.count <= 3,
                     "REFERENCE_2_VIDEO mode requires 1-3 images")

        return Veo31Request(
            prompt: prompt,
            imageUrls: imageUrls,
            model: .veo3_fast,  // Only fast model supports reference mode
            mode: .reference2Video,
            aspectRatio: .landscape  // Only 16:9 supported
        )
    }
}

/// Veo 3.1 API response.
public struct Veo31Response: Codable, Sendable {
    /// Response status code.
    public let code: Int

    /// Response message or error details.
    public let message: String

    /// Task ID for polling (if async).
    public let data: Veo31Data?

    public struct Veo31Data: Codable, Sendable {
        /// The task ID for async generation.
        public let taskId: String

        /// Current task status.
        public let status: String?

        /// Video URL (if immediately available).
        public let videoUrl: URL?

        enum CodingKeys: String, CodingKey {
            case taskId = "task_id"
            case status
            case videoUrl = "video_url"
        }
    }

    /// Whether the request was successful.
    public var isSuccess: Bool {
        return code == 200
    }
}
