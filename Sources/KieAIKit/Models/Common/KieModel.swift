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

    /// Google Nano Banana Edit - Image-to-image editing (ASYNC TASK)
    /// Model identifier: "google/nano-banana-edit"
    /// Documentation: https://docs.kie.ai/market/google/nano-banana-edit
    ///
    /// This model creates an async task for image editing. Requires source image URLs.
    /// Use `edit()` method with `ImageEditRequest` and `waitForResult()` to poll for completion.
    case googleNanoBananaEdit = "google/nano-banana-edit"

    /// Nano Banana Pro - Image generation (text-to-image and image-to-image) (ASYNC TASK)
    /// Model identifier: "nano-banana-pro"
    /// Documentation: https://docs.kie.ai/market/google/pro-image-to-image
    ///
    /// This model supports both text-to-image and image-to-image generation.
    /// - Text-to-image: use `NanoBananaProRequest.textToImage(prompt:)`
    /// - Image-to-image: use `NanoBananaProRequest.imageToImage(prompt:imageURL:)`
    /// Supports resolution control (1K/2K/4K), inpainting, and outpainting.
    /// Use `nanoBananaPro()` method with `NanoBananaProRequest` and `waitForResult()` to poll for completion.
    case nanoBananaPro = "nano-banana-pro"

    /// Nano Banana 2 - Image generation (text-to-image and image-to-image) (ASYNC TASK)
    /// Model identifier: "nano-banana-2"
    /// Documentation: https://docs.kie.ai/market/google/nanobanana2
    ///
    /// Next-gen model combining Pro-level intelligence with fast generation.
    /// Supports up to 14 reference images, search-grounded generation, and 4K output.
    /// Use `nanoBanana2()` method with `NanoBanana2Request` and `waitForResult()` to poll for completion.
    case nanoBanana2 = "nano-banana-2"

    /// Veo 3.1 Text-to-Video - Text-to-video generation (ASYNC TASK)
    /// Model identifier: "veo-3.1/text-to-video"
    /// Documentation: https://kie.ai/veo-3-1
    ///
    /// This model creates an async task for text-to-video generation with Google's latest Veo 3.1.
    /// Supports native audio, multi-image reference, start & end frame control, and extended scenes.
    /// Available in Fast and Quality variants.
    /// Use `veo31TextToVideo()` method with `Veo31TextToVideoRequest` and `waitForResult()` to poll for completion.
    case veo31TextToVideo = "veo-3.1/text-to-video"

    /// Veo 3.1 Image-to-Video - Image-to-video generation (ASYNC TASK)
    /// Model identifier: "veo-3.1/image-to-video"
    /// Documentation: https://kie.ai/veo-3-1
    ///
    /// This model creates an async task for image-to-video generation with Google's latest Veo 3.1.
    /// Supports native audio, multi-image reference, start & end frame control, and extended scenes.
    /// Available in Fast and Quality variants.
    /// Use `veo31ImageToVideo()` method with `Veo31ImageToVideoRequest` and `waitForResult()` to poll for completion.
    case veo31ImageToVideo = "veo-3.1/image-to-video"

    // MARK: - Execution Type

    /// The execution type for this model (immediate vs async task)
    public var executionType: ExecutionType {
        switch self {
        case .gptImage15:
            return .immediate
        case .flux2Flex, .kling26, .googleNanoBananaEdit, .nanoBananaPro, .nanoBanana2, .veo31TextToVideo, .veo31ImageToVideo:
            return .asyncTask
        }
    }

    // MARK: - Helper Methods

    /// Returns all verified image generation models.
    public static var allImageModels: [KieModel] {
        return [.gptImage15, .flux2Flex, .googleNanoBananaEdit, .nanoBananaPro, .nanoBanana2]
    }

    /// Returns all verified video generation models.
    public static var allVideoModels: [KieModel] {
        return [.kling26, .veo31TextToVideo, .veo31ImageToVideo]
    }
}
