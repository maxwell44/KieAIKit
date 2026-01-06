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
        // Build the request body based on the model type
        // Different models require different input structures
        let inputDict = buildInputForModel(model, request: request)

        // Debug: Print the request body
        #if DEBUG
        struct DebugBody: Encodable {
            let model: String
            let input: [String: AnyCodable]
            init(model: String, input: [String: Any]) {
                self.model = model
                self.input = input.mapValues { AnyCodable($0) }
            }
        }
        let debugBody = DebugBody(model: model.rawValue, input: inputDict)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        if let jsonData = try? encoder.encode(debugBody),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🔍 KieAIKit Request Body:")
            print(jsonString)
        }
        #endif

        // Create request using AnyCodable
        struct DynamicBody: Encodable {
            let model: String
            let input: [String: AnyCodable]

            init(model: String, input: [String: Any]) {
                self.model = model
                self.input = input.mapValues { AnyCodable($0) }
            }
        }

        let body = DynamicBody(
            model: model.rawValue,
            input: inputDict
        )

        let apiRequest = APIRequest(
            path: "jobs/createTask",
            method: .post,
            body: body
        )

        // The API returns a wrapped response with task ID
        let taskResponse = try await apiClient.performAndUnwrap(apiRequest, as: TaskCreationResponse.self)

        // Create a TaskInfo from the task ID
        let taskInfo = TaskInfo(id: taskResponse.taskId, status: .pending)

        // Validate the task info before returning
        try taskInfo.validate()

        return taskInfo
    }

    /// Builds the input object for a specific model.
    private func buildInputForModel(_ model: KieModel, request: ImageGenerationRequest) -> [String: Any] {
        var input: [String: Any] = ["prompt": request.prompt]

        switch model {
        case .gptImage15:
            // GPT Image requires aspect_ratio (string) and quality
            if let width = request.width, let height = request.height {
                // Convert width/height to aspect_ratio string
                let gcd = greatestCommonDivisor(width, height)
                input["aspect_ratio"] = "\(width/gcd):\(height/gcd)"
            } else {
                input["aspect_ratio"] = "1:1"  // Default
            }
            input["quality"] = "medium"  // Default quality

        case .flux2Flex:
            // Flux-2 requires aspect_ratio (string) and resolution (string)
            if let width = request.width, let height = request.height {
                // Convert width/height to aspect_ratio string
                let gcd = greatestCommonDivisor(width, height)
                input["aspect_ratio"] = "\(width/gcd):\(height/gcd)"
            } else {
                input["aspect_ratio"] = "1:1"  // Default
            }
            input["resolution"] = "1K"  // Default resolution

        default:
            // For other models, use the traditional width/height/negativePrompt fields
            if let negativePrompt = request.negativePrompt {
                input["negative_prompt"] = negativePrompt
            }
            if let count = request.count {
                input["count"] = count
            }
            if let width = request.width {
                input["width"] = width
            }
            if let height = request.height {
                input["height"] = height
            }
            if let seed = request.seed {
                input["seed"] = seed
            }
        }

        return input
    }

    /// Helper function to calculate GCD for aspect ratio
    private func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        let a = abs(a)
        let b = abs(b)
        if b == 0 { return a }
        return greatestCommonDivisor(b, a % b)
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
        let finalTaskInfo = try await poller.poll(
            taskId: task.id,
            endpoint: "jobs/recordInfo?taskId",
            interval: interval,
            timeout: timeout
        )

        // Build result from the completed task info
        guard let resultURL = finalTaskInfo.resultURL else {
            throw APIError.serverError("Task completed but no result URL provided")
        }

        return ImageGenerationResult(
            taskId: finalTaskInfo.id,
            imageUrls: [resultURL],
            model: finalTaskInfo.model ?? "unknown",
            prompt: "",  // Prompt not returned in task status
            width: nil,
            height: nil,
            seed: nil,
            metadata: finalTaskInfo.metadata
        )
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
