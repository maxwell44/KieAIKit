//
//  NanoBanana2Request.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Request parameters for Nano Banana 2 image generation.
///
/// This next-gen model combines Pro-level intelligence with fast generation.
/// Supports text-to-image and image-to-image with up to 14 reference images.
///
/// - For text-to-image: omit `imageInput` (or pass nil).
/// - For image-to-image: provide up to 14 reference images via `imageInput`.
///
/// Official docs: https://docs.kie.ai/market/google/nanobanana2
public struct NanoBanana2Request: Codable, Sendable {

    /// The text prompt describing the desired image (max 20,000 characters).
    public let prompt: String

    /// Aspect ratio of the output image.
    /// Options: 1:1, 1:4, 1:8, 2:3, 3:2, 3:4, 4:1, 4:3, 4:5, 5:4, 8:1, 9:16, 16:9, 21:9, auto.
    /// Default: "auto".
    public let aspectRatio: String

    /// Resolution of the output image: "1K", "2K", or "4K".
    /// Default: "1K".
    public let resolution: String

    /// Output format: "png" or "jpg".
    /// Default: "jpg".
    public let outputFormat: String

    /// Optional array of source image URLs for image-to-image generation.
    /// Supports up to 14 images.
    /// Omit for text-to-image.
    public let imageInput: [URL]?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case aspectRatio = "aspect_ratio"
        case resolution
        case outputFormat = "output_format"
        case imageInput = "image_input"
    }

    /// Maximum prompt length for Nano Banana 2 (official limit: 20,000 characters).
    public static let maxPromptLength = 20_000

    public init(
        prompt: String,
        aspectRatio: String = "auto",
        resolution: String = "1K",
        outputFormat: String = "jpg",
        imageInput: [URL]? = nil
    ) {
        precondition(
            prompt.count <= Self.maxPromptLength,
            "Nano Banana 2 prompt exceeds \(Self.maxPromptLength) characters (got \(prompt.count)). The API will return a 422 validation error."
        )
        self.prompt = prompt
        self.aspectRatio = aspectRatio
        self.resolution = resolution
        self.outputFormat = outputFormat
        self.imageInput = imageInput
    }

    // MARK: - Convenience Initializers

    /// Creates a text-to-image request (no reference images).
    public static func textToImage(
        prompt: String,
        aspectRatio: String = "auto",
        resolution: String = "1K",
        outputFormat: String = "jpg"
    ) -> NanoBanana2Request {
        return NanoBanana2Request(
            prompt: prompt,
            aspectRatio: aspectRatio,
            resolution: resolution,
            outputFormat: outputFormat,
            imageInput: nil
        )
    }

    /// Creates an image-to-image request with a single reference image.
    public static func imageToImage(
        prompt: String,
        imageURL: URL,
        aspectRatio: String = "auto",
        resolution: String = "1K",
        outputFormat: String = "jpg"
    ) -> NanoBanana2Request {
        return NanoBanana2Request(
            prompt: prompt,
            aspectRatio: aspectRatio,
            resolution: resolution,
            outputFormat: outputFormat,
            imageInput: [imageURL]
        )
    }

    /// Creates an image-to-image request with multiple reference images (up to 14).
    public static func imageToImage(
        prompt: String,
        imageURLs: [URL],
        aspectRatio: String = "auto",
        resolution: String = "1K",
        outputFormat: String = "jpg"
    ) -> NanoBanana2Request {
        return NanoBanana2Request(
            prompt: prompt,
            aspectRatio: aspectRatio,
            resolution: resolution,
            outputFormat: outputFormat,
            imageInput: imageURLs
        )
    }

    // MARK: - Common Values

    /// Aspect ratios supported by Nano Banana 2.
    public enum AspectRatio {
        public static let square = "1:1"
        public static let one4 = "1:4"
        public static let one8 = "1:8"
        public static let two3 = "2:3"
        public static let three2 = "3:2"
        public static let three4 = "3:4"
        public static let four1 = "4:1"
        public static let four3 = "4:3"
        public static let four5 = "4:5"
        public static let five4 = "5:4"
        public static let eight1 = "8:1"
        public static let portrait = "9:16"
        public static let landscape = "16:9"
        public static let cinematic = "21:9"
        public static let auto = "auto"
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
    }
}
