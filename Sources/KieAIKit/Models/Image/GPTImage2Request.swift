//
//  GPTImage2Request.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Request parameters for GPT Image 2 generation and editing.
///
/// GPT Image 2 has two KIE model identifiers:
/// - Text-to-image: `gpt-image-2-text-to-image`
/// - Image-to-image: `gpt-image-2-image-to-image`
///
/// The SDK chooses the model automatically: omit `inputURLs` for text-to-image,
/// or provide one or more reference images for image-to-image.
public struct GPTImage2Request: Codable, Sendable {

    /// The text prompt describing the desired image.
    public let prompt: String

    /// Optional reference image URLs for image-to-image generation.
    /// KIE currently supports up to 16 images, with JPEG, PNG, WEBP, and JPG formats.
    public let inputURLs: [URL]?

    /// Aspect ratio of the output image.
    /// Options: auto, 1:1, 9:16, 16:9, 4:3, 3:4.
    /// Default: "auto".
    public let aspectRatio: String

    /// Optional output resolution: "1K", "2K", or "4K".
    /// Note: 4K is not supported for 1:1. Auto aspect ratio only supports 1K.
    public let resolution: String?

    /// Optional NSFW checker flag supported by KIE examples.
    public let nsfwChecker: Bool?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case inputURLs = "input_urls"
        case aspectRatio = "aspect_ratio"
        case resolution
        case nsfwChecker = "nsfw_checker"
    }

    public init(
        prompt: String,
        inputURLs: [URL]? = nil,
        aspectRatio: String = AspectRatio.auto,
        resolution: String? = nil,
        nsfwChecker: Bool? = nil
    ) {
        self.prompt = prompt
        self.inputURLs = inputURLs
        self.aspectRatio = aspectRatio
        self.resolution = resolution
        self.nsfwChecker = nsfwChecker
    }

    /// Creates a text-to-image request.
    public static func textToImage(
        prompt: String,
        aspectRatio: String = AspectRatio.auto,
        resolution: String? = nil,
        nsfwChecker: Bool? = nil
    ) -> GPTImage2Request {
        return GPTImage2Request(
            prompt: prompt,
            aspectRatio: aspectRatio,
            resolution: resolution,
            nsfwChecker: nsfwChecker
        )
    }

    /// Creates an image-to-image request with a single reference image.
    public static func imageToImage(
        prompt: String,
        imageURL: URL,
        aspectRatio: String = AspectRatio.auto,
        resolution: String? = nil,
        nsfwChecker: Bool? = nil
    ) -> GPTImage2Request {
        return GPTImage2Request(
            prompt: prompt,
            inputURLs: [imageURL],
            aspectRatio: aspectRatio,
            resolution: resolution,
            nsfwChecker: nsfwChecker
        )
    }

    /// Creates an image-to-image request with multiple reference images.
    public static func imageToImage(
        prompt: String,
        imageURLs: [URL],
        aspectRatio: String = AspectRatio.auto,
        resolution: String? = nil,
        nsfwChecker: Bool? = nil
    ) -> GPTImage2Request {
        return GPTImage2Request(
            prompt: prompt,
            inputURLs: imageURLs,
            aspectRatio: aspectRatio,
            resolution: resolution,
            nsfwChecker: nsfwChecker
        )
    }

    /// Aspect ratios supported by GPT Image 2.
    public enum AspectRatio {
        public static let auto = "auto"
        public static let square = "1:1"
        public static let portrait = "9:16"
        public static let landscape = "16:9"
        public static let four3 = "4:3"
        public static let three4 = "3:4"
    }

    /// Resolution options supported by GPT Image 2.
    public enum Resolution {
        public static let r1K = "1K"
        public static let r2K = "2K"
        public static let r4K = "4K"
    }
}
