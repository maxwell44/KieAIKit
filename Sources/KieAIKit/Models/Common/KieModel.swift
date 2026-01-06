//
//  KieModel.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// A strongly-typed enumeration of available Kie.ai AI models.
///
/// This enum provides type safety when specifying which model to use for generation.
/// Do not use arbitrary strings - always use these predefined cases.
public enum KieModel: String, Codable, Sendable {

    // MARK: - Image Generation Models

    /// GPT Image 1.5 - Advanced text-to-image generation
    case gptImage15 = "gpt-image-1.5"

    /// Seedream 4.5 - High-quality image synthesis
    case seedream45 = "seedream-4.5"

    /// Flux 2 - Fast image generation model
    case flux2 = "flux-2"

    /// Z-Image - Specialized image generation
    case zImage = "z-image"

    // MARK: - Video Generation Models

    /// Kling 2.6 - Advanced video generation
    case kling26 = "kling-2.6"

    /// Wan 2.6 - High-quality video synthesis
    case wan26 = "wan-2.6"

    /// Seedance 1.5 Pro - Professional dance and motion video generation
    case seedance15Pro = "seedance-1.5-pro"

    // MARK: - Audio Generation Models

    /// Placeholder for audio models (add actual model names when available)
    // Uncomment when audio models are documented:
    // case audioModel1 = "audio-model-1"

    /// Returns all image generation models.
    public static var allImageModels: [KieModel] {
        return [.gptImage15, .seedream45, .flux2, .zImage]
    }

    /// Returns all video generation models.
    public static var allVideoModels: [KieModel] {
        return [.kling26, .wan26, .seedance15Pro]
    }

    /// Returns all audio generation models.
    public static var allAudioModels: [KieModel] {
        // Add audio models when available
        return []
    }
}
