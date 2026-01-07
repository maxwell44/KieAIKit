//
//  NanoBananaProRequest.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Request parameters for Nano Banana Pro advanced image generation.
///
/// This model supports enhanced image generation with resolution control
/// and flexible aspect ratios.
public struct NanoBananaProRequest: Codable, Sendable {

    /// The text prompt describing the desired image.
    public let prompt: String

    /// Aspect ratio of the output image (e.g., "1:1", "16:9", "9:16").
    public let aspectRatio: String

    /// Resolution of the output image (e.g., "1K", "2K", "4K").
    public let resolution: String

    /// Output format (e.g., "png", "jpg", "webp").
    public let outputFormat: String

    /// Array of source image URLs for image-to-image generation.
    public let imageInput: [URL]

    private enum CodingKeys: String, CodingKey {
        case prompt
        case aspectRatio = "aspect_ratio"
        case resolution
        case outputFormat = "output_format"
        case imageInput = "image_input"
    }

    public init(
        prompt: String,
        aspectRatio: String,
        resolution: String,
        outputFormat: String,
        imageInput: [URL]
    ) {
        self.prompt = prompt
        self.aspectRatio = aspectRatio
        self.resolution = resolution
        self.outputFormat = outputFormat
        self.imageInput = imageInput
    }

    // MARK: - Convenience Initializers

    /// Creates a request with a single image URL.
    public static func with(
        prompt: String,
        imageURL: URL,
        aspectRatio: String = "1:1",
        resolution: String = "1K",
        outputFormat: String = "png"
    ) -> NanoBananaProRequest {
        return NanoBananaProRequest(
            prompt: prompt,
            aspectRatio: aspectRatio,
            resolution: resolution,
            outputFormat: outputFormat,
            imageInput: [imageURL]
        )
    }

    /// Creates a request with multiple image URLs.
    public static func with(
        prompt: String,
        imageUrls: [URL],
        aspectRatio: String = "1:1",
        resolution: String = "1K",
        outputFormat: String = "png"
    ) -> NanoBananaProRequest {
        return NanoBananaProRequest(
            prompt: prompt,
            aspectRatio: aspectRatio,
            resolution: resolution,
            outputFormat: outputFormat,
            imageInput: imageUrls
        )
    }

    // MARK: - Common Values

    /// Common aspect ratios.
    public enum AspectRatio {
        public static let square = "1:1"
        public static let landscape = "16:9"
        public static let portrait = "9:16"
        public static let four3 = "4:3"
        public static let three4 = "3:4"
        public static let cinematic = "21:9"
    }

    /// Resolution options.
    public enum Resolution {
        public static let r1K = "1K"
        public static let r2K = "2K"
        public static let r4K = "4K"
    }

    /// Output format options.
    public enum OutputFormat {
        public static let png = "png"
        public static let jpg = "jpg"
        public static let webp = "webp"
    }
}
