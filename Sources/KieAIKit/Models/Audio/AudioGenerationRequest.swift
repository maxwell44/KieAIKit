//
//  AudioGenerationRequest.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Request parameters for audio generation.
public struct AudioGenerationRequest: Codable, Sendable {

    /// The text prompt describing the audio to generate.
    public let prompt: String

    /// Duration of the audio in seconds.
    public let duration: Double?

    /// Type of audio to generate.
    public let audioType: AudioType?

    /// Seed for reproducible generation.
    public let seed: Int?

    /// Additional model-specific parameters.
    public let parameters: [String: AnyCodable]?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case duration
        case audioType = "audio_type"
        case seed
        case parameters
    }

    public init(
        prompt: String,
        duration: Double? = nil,
        audioType: AudioType? = nil,
        seed: Int? = nil,
        parameters: [String: Any]? = nil
    ) {
        self.prompt = prompt
        self.duration = duration
        self.audioType = audioType
        self.seed = seed

        if let parameters = parameters {
            self.parameters = parameters.mapValues { AnyCodable($0) }
        } else {
            self.parameters = nil
        }
    }

    /// Types of audio that can be generated.
    public enum AudioType: String, Codable, Sendable {
        case music
        case speech
        case soundEffect = "sound_effect"
        case ambient
    }

    /// Creates a request with common presets.
    public static func with(
        prompt: String,
        duration: Double = 30.0,
        audioType: AudioType = .music
    ) -> AudioGenerationRequest {
        return AudioGenerationRequest(
            prompt: prompt,
            duration: duration,
            audioType: audioType
        )
    }
}
