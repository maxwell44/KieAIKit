//
//  ImageEditRequest.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Request parameters for image editing (image-to-image).
///
/// Used for models like Google Nano Banana Edit that transform existing images
/// based on text prompts.
public struct ImageEditRequest: Codable, Sendable {

    /// The text prompt describing how to edit the image.
    public let prompt: String

    /// Array of source image URLs to edit.
    public let imageURLs: [URL]

    /// Output format (e.g., "png", "jpg").
    public let outputFormat: String?

    /// Image size as aspect ratio (e.g., "1:1", "16:9", "9:16").
    public let imageSize: String?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case imageURLs = "image_urls"
        case outputFormat = "output_format"
        case imageSize = "image_size"
    }

    public init(
        prompt: String,
        imageURLs: [URL],
        outputFormat: String? = nil,
        imageSize: String? = nil
    ) {
        self.prompt = prompt
        self.imageURLs = imageURLs
        self.outputFormat = outputFormat
        self.imageSize = imageSize
    }

    /// Common aspect ratios.
    public enum AspectRatio {
        public static let square = "1:1"
        public static let landscape = "16:9"
        public static let portrait = "9:16"
        public static let four3 = "4:3"
        public static let three4 = "3:4"
    }

    /// Common output formats.
    public enum OutputFormat {
        public static let png = "png"
        public static let jpg = "jpg"
        public static let webp = "webp"
    }

    /// Creates a request with a single image URL.
    public static func with(
        prompt: String,
        imageURL: URL,
        outputFormat: String? = nil,
        imageSize: String? = nil
    ) -> ImageEditRequest {
        return ImageEditRequest(
            prompt: prompt,
            imageURLs: [imageURL],
            outputFormat: outputFormat,
            imageSize: imageSize
        )
    }

    /// Creates a request with multiple image URLs.
    public static func with(
        prompt: String,
        imageURLs: [URL],
        outputFormat: String? = nil,
        imageSize: String? = nil
    ) -> ImageEditRequest {
        return ImageEditRequest(
            prompt: prompt,
            imageURLs: imageURLs,
            outputFormat: outputFormat,
            imageSize: imageSize
        )
    }
}
