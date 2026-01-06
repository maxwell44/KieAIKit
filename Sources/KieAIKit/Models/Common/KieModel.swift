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
/// https://docs.kie.ai/market
///
/// Do NOT use model names from OpenAI, Anthropic, or other official sources.
/// KIE uses its own model naming convention.
///
/// To add new models, visit https://docs.kie.ai/market to find the exact model identifier.
public enum KieModel: String, Codable, Sendable {

    // MARK: - Verified Models

    /// GPT Image 1.5 - Text-to-image generation
    /// Model identifier: "gpt-image/1.5-text-to-image"
    /// Documentation: https://docs.kie.ai/market/gpt-image
    case gptImage15 = "gpt-image/1.5-text-to-image"

    /// Flux 2 - Text-to-image generation
    /// Model identifier: "flux-2/flex-text-to-image"
    /// Documentation: https://docs.kie.ai/market/flux2/flex-text-to-image
    case flux2Flex = "flux-2/flex-text-to-image"

    /// Kling 2.6 - Text-to-video generation
    /// Model identifier: "kling-2.6/text-to-video"
    /// Documentation: https://docs.kie.ai/market/kling
    case kling26 = "kling-2.6/text-to-video"

    // MARK: - Helper Methods

    /// Returns all verified image generation models.
    public static var allImageModels: [KieModel] {
        return [.gptImage15, .flux2Flex]
    }

    /// Returns all verified video generation models.
    public static var allVideoModels: [KieModel] {
        return [.kling26]
    }
}
