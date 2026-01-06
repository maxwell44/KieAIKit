//
//  ImageService.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Service for generating images using the Kie.ai API.
public final class ImageService {

    /// The API client for making requests.
    private let apiClient: APIClient

    /// The task poller for waiting for results.
    private let poller: TaskPoller

    /// Creates a new image service.
    /// - Parameter apiClient: The API client to use
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        self.poller = TaskPoller(apiClient: apiClient)
    }

    /// Generates an image using the specified model and prompt.
    ///
    /// This method initiates an asynchronous image generation task and returns
    /// immediately with a task ID. Use the returned task info with `waitForResult`
    /// to poll for completion.
    ///
    /// - Parameters:
    ///   - model: The AI model to use for generation
    ///   - request: The generation request parameters
    /// - Returns: A TaskInfo containing the task ID
    /// - Throws: An APIError if the request fails
    public func generate(
        model: KieModel,
        request: ImageGenerationRequest
    ) async throws -> TaskInfo {
        struct GenerationBody: Codable {
            let model: String
            let prompt: String
            let negativePrompt: String?
            let count: Int?
            let width: Int?
            let height: Int?
            let seed: Int?
            let parameters: [String: AnyCodable]?

            enum CodingKeys: String, CodingKey {
                case model
                case prompt
                case negativePrompt = "negative_prompt"
                case count
                case width
                case height
                case seed
                case parameters
            }
        }

        let body = GenerationBody(
            model: model.rawValue,
            prompt: request.prompt,
            negativePrompt: request.negativePrompt,
            count: request.count,
            width: request.width,
            height: request.height,
            seed: request.seed,
            parameters: request.parameters
        )

        let apiRequest = APIRequest(
            path: "images/generate",
            method: .post,
            body: body
        )

        // The API returns a task info with the task ID
        return try await apiClient.perform(apiRequest, as: TaskInfo.self)
    }

    /// Waits for an image generation task to complete and returns the result.
    ///
    /// - Parameters:
    ///   - task: The task info returned from `generate`
    ///   - interval: Seconds between polling attempts (default: 2)
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The image generation result
    /// - Throws: An APIError if polling fails or times out
    public func waitForResult(
        task: TaskInfo,
        interval: TimeInterval = 2.0,
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        // Poll until complete, result contains the final task status
        _ = try await poller.poll(
            taskId: task.id,
            endpoint: "images/tasks",
            interval: interval,
            timeout: timeout
        )

        // Now fetch the actual result
        let request = APIRequest<EmptyRequestBody>(
            path: "images/results/\(task.id)",
            method: .get
        )

        return try await apiClient.perform(request, as: ImageGenerationResult.self)
    }

    /// Generates an image and waits for completion in one call.
    ///
    /// This is a convenience method that combines `generate` and `waitForResult`.
    ///
    /// - Parameters:
    ///   - model: The AI model to use for generation
    ///   - request: The generation request parameters
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The image generation result
    /// - Throws: An APIError if generation or polling fails
    public func generateAndWait(
        model: KieModel,
        request: ImageGenerationRequest,
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        let task = try await generate(model: model, request: request)
        return try await waitForResult(task: task, timeout: timeout)
    }
}
