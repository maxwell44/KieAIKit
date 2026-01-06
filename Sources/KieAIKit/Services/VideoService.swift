//
//  VideoService.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Service for generating videos using the Kie.ai API.
public final class VideoService {

    /// The API client for making requests.
    private let apiClient: APIClient

    /// The task poller for waiting for results.
    private let poller: TaskPoller

    /// Creates a new video service.
    /// - Parameter apiClient: The API client to use
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        self.poller = TaskPoller(apiClient: apiClient)
    }

    /// Generates a video using the specified model and prompt.
    ///
    /// This method initiates an asynchronous video generation task and returns
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
        request: VideoGenerationRequest
    ) async throws -> TaskInfo {
        struct GenerationBody: Codable {
            let model: String
            let prompt: String
            let negativePrompt: String?
            let duration: Int?
            let aspectRatio: String?
            let fps: Int?
            let seed: Int?
            let initImageURL: URL?
            let parameters: [String: AnyCodable]?

            enum CodingKeys: String, CodingKey {
                case model
                case prompt
                case negativePrompt = "negative_prompt"
                case duration
                case aspectRatio = "aspect_ratio"
                case fps
                case seed
                case initImageURL = "init_image_url"
                case parameters
            }
        }

        let body = GenerationBody(
            model: model.rawValue,
            prompt: request.prompt,
            negativePrompt: request.negativePrompt,
            duration: request.duration,
            aspectRatio: request.aspectRatio?.rawValue,
            fps: request.fps,
            seed: request.seed,
            initImageURL: request.initImageURL,
            parameters: request.parameters
        )

        let apiRequest = APIRequest(
            path: "videos/generate",
            method: .post,
            body: body
        )

        return try await apiClient.perform(apiRequest, as: TaskInfo.self)
    }

    /// Waits for a video generation task to complete and returns the result.
    ///
    /// - Parameters:
    ///   - task: The task info returned from `generate`
    ///   - interval: Seconds between polling attempts (default: 2)
    ///   - timeout: Maximum time to wait before timing out (default: 600 seconds for video)
    /// - Returns: The video generation result
    /// - Throws: An APIError if polling fails or times out
    public func waitForResult(
        task: TaskInfo,
        interval: TimeInterval = 2.0,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        // Poll until complete, result contains the final task status
        _ = try await poller.poll(
            taskId: task.id,
            endpoint: "videos/tasks",
            interval: interval,
            timeout: timeout
        )

        // Now fetch the actual result
        let request = APIRequest<EmptyRequestBody>(
            path: "videos/results/\(task.id)",
            method: .get
        )

        return try await apiClient.perform(request, as: VideoGenerationResult.self)
    }

    /// Generates a video and waits for completion in one call.
    ///
    /// This is a convenience method that combines `generate` and `waitForResult`.
    ///
    /// - Parameters:
    ///   - model: The AI model to use for generation
    ///   - request: The generation request parameters
    ///   - timeout: Maximum time to wait before timing out (default: 600 seconds)
    /// - Returns: The video generation result
    /// - Throws: An APIError if generation or polling fails
    public func generateAndWait(
        model: KieModel,
        request: VideoGenerationRequest,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        let task = try await generate(model: model, request: request)
        return try await waitForResult(task: task, timeout: timeout)
    }
}
