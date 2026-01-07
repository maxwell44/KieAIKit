//
//  KieModel.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// The execution type for a model (sync vs async)
public enum ExecutionType: Sendable {
    /// Model returns results immediately in the response
    case immediate

    /// Model creates an async task that requires polling
    case asyncTask
}

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
/// **Execution Types:**
/// - `.immediate` models return results directly (no task ID, no polling needed)
/// - `.asyncTask` models create a task and require polling for results
///
/// To add new models, visit https://docs.kie.ai/market to find the exact model identifier.
public enum KieModel: String, Codable, Sendable {

    // MARK: - Verified Models

    /// GPT Image 1.5 - Text-to-image generation (IMMEDIATE)
    /// Model identifier: "gpt-image/1.5-text-to-image"
    /// Documentation: https://docs.kie.ai/market/gpt-image
    ///
    /// ⚠️ This model uses a **direct response API** and does NOT support async task polling.
    /// Results are returned immediately in the response.
    case gptImage15 = "gpt-image/1.5-text-to-image"

    /// Flux 2 - Text-to-image generation (ASYNC TASK)
    /// Model identifier: "flux-2/flex-text-to-image"
    /// Documentation: https://docs.kie.ai/market/flux2/flex-text-to-image
    ///
    /// This model creates an async task. Use `waitForResult()` to poll for completion.
    case flux2Flex = "flux-2/flex-text-to-image"

    /// Kling 2.6 - Text-to-video generation (ASYNC TASK)
    /// Model identifier: "kling-2.6/text-to-video"
    /// Documentation: https://docs.kie.ai/market/kling
    ///
    /// This model creates an async task. Use `waitForResult()` to poll for completion.
    case kling26 = "kling-2.6/text-to-video"

    // MARK: - Execution Type

    /// The execution type for this model (immediate vs async task)
    public var executionType: ExecutionType {
        switch self {
        case .gptImage15:
            return .immediate
        case .flux2Flex, .kling26:
            return .asyncTask
        }
    }

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
