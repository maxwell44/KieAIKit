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
///
/// ⚠️ IMPORTANT: Model names must match exactly what's listed in the KIE Market.
/// https://docs.kie.ai/cn/market
///
/// Do NOT use model names from OpenAI, Anthropic, or other official sources.
/// KIE uses its own model naming convention.
public enum KieModel: String, Codable, Sendable {

    // MARK: - Image Generation Models

    /// GPT Image 1.5 - Advanced text-to-image generation
    /// Model identifier: "gpt-image/1.5-text-to-image"
    /// Documentation: https://docs.kie.ai/cn/market/gpt-image
    case gptImage15 = "gpt-image/1.5-text-to-image"

    /// Seedream 4.5 - High-quality image synthesis
    /// Documentation: https://docs.kie.ai/cn/market/seedream
    case seedream45 = "seedream-4.5"

    /// Flux 2 - Fast image generation model
    /// Documentation: https://docs.kie.ai/cn/market/flux-2
    case flux2 = "flux-2"

    /// Z-Image - Specialized image generation
    /// Documentation: https://docs.kie.ai/cn/market/z-image
    case zImage = "z-image"

    // MARK: - Video Generation Models

    /// Kling 2.6 - Advanced video generation (text-to-video)
    /// Model identifier: "kling-2.6/text-to-video"
    /// Documentation: https://docs.kie.ai/cn/market/kling
    case kling26 = "kling-2.6/text-to-video"

    /// Wan 2.6 - High-quality video synthesis
    /// Documentation: https://docs.kie.ai/cn/market/wan
    case wan26 = "wan-2.6"

    /// Seedance 1.5 Pro - Professional dance and motion video generation
    /// Documentation: https://docs.kie.ai/cn/market/seedance
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
