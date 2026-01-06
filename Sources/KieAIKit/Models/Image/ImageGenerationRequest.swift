//
//  ImageGenerationRequest.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Request parameters for image generation.
public struct ImageGenerationRequest: Codable, Sendable {

    /// The text prompt describing the image to generate.
    public let prompt: String

    /// Negative prompt - what to avoid in the generated image.
    public let negativePrompt: String?

    /// The number of images to generate (typically 1-4).
    public let count: Int?

    /// Width of the generated image in pixels.
    public let width: Int?

    /// Height of the generated image in pixels.
    public let height: Int?

    /// Seed for reproducible generation.
    public let seed: Int?

    /// Additional model-specific parameters.
    public let parameters: [String: AnyCodable]?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case negativePrompt = "negative_prompt"
        case count
        case width
        case height
        case seed
        case parameters
    }

    public init(
        prompt: String,
        negativePrompt: String? = nil,
        count: Int? = nil,
        width: Int? = nil,
        height: Int? = nil,
        seed: Int? = nil,
        parameters: [String: Any]? = nil
    ) {
        self.prompt = prompt
        self.negativePrompt = negativePrompt
        self.count = count
        self.width = width
        self.height = height
        self.seed = seed

        if let parameters = parameters {
            self.parameters = parameters.mapValues { AnyCodable($0) }
        } else {
            self.parameters = nil
        }
    }

    /// Common image size presets.
    public enum ImageSize {
        public static let square = (width: 1024, height: 1024)
        public static let landscape = (width: 1920, height: 1080)
        public static let portrait = (width: 1080, height: 1920)
    }

    /// Creates a request with common image size presets.
    public static func with(
        prompt: String,
        size: (width: Int, height: Int)? = nil,
        negativePrompt: String? = nil,
        count: Int? = 1
    ) -> ImageGenerationRequest {
        return ImageGenerationRequest(
            prompt: prompt,
            negativePrompt: negativePrompt,
            count: count,
            width: size?.width,
            height: size?.height
        )
    }
}

/// Type-erased wrapper for any Codable value.
public struct AnyCodable: Codable, Sendable {
    private let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            value = ()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        case let dictValue as [String: Any]:
            try container.encode(dictValue.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
