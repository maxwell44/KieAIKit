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
        guard !finalTaskInfo.resultURLs.isEmpty else {
            throw APIError.serverError("Task completed but no result URL provided")
        }

        return ImageGenerationResult(
            taskId: finalTaskInfo.id,
            imageUrls: finalTaskInfo.resultURLs,
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

    // MARK: - Image Editing (Image-to-Image)

    /// Edits an image using the specified model and edit request.
    ///
    /// This method initiates an asynchronous image editing task and returns
    /// immediately with a task ID. Use the returned task info with `waitForResult`
    /// to poll for completion.
    ///
    /// - Parameters:
    ///   - model: The AI model to use for editing (e.g., .googleNanoBananaEdit)
    ///   - request: The edit request parameters
    /// - Returns: A TaskInfo containing the task ID
    /// - Throws: An APIError if the request fails
    public func edit(
        model: KieModel,
        request: ImageEditRequest
    ) async throws -> TaskInfo {
        // Build the request body for image editing
        var input: [String: Any] = [
            "prompt": request.prompt,
            "image_urls": request.imageURLs.map { $0.absoluteString }
        ]

        // Add optional parameters
        if let outputFormat = request.outputFormat {
            input["output_format"] = outputFormat
        }
        if let imageSize = request.imageSize {
            input["image_size"] = imageSize
        }

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
        let debugBody = DebugBody(model: model.rawValue, input: input)
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
            input: input
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

    /// Edits an image and waits for completion in one call.
    ///
    /// This is a convenience method that combines `edit` and `waitForResult`.
    ///
    /// - Parameters:
    ///   - model: The AI model to use for editing
    ///   - request: The edit request parameters
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The image generation result
    /// - Throws: An APIError if editing or polling fails
    public func editAndWait(
        model: KieModel,
        request: ImageEditRequest,
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        let task = try await edit(model: model, request: request)
        return try await waitForResult(task: task, timeout: timeout)
    }

    // MARK: - GPT Image 2

    /// Generates or edits an image using GPT Image 2.
    ///
    /// This method automatically selects the correct KIE model identifier:
    /// - `gpt-image-2-text-to-image` when `inputURLs` is empty or nil.
    /// - `gpt-image-2-image-to-image` when reference image URLs are provided.
    ///
    /// - Parameters:
    ///   - request: The GPT Image 2 request parameters
    ///   - callBackUrl: Optional URL to receive task completion notifications
    /// - Returns: A TaskInfo containing the task ID
    /// - Throws: An APIError if the request fails
    public func gptImage2(
        request: GPTImage2Request,
        callBackUrl: URL? = nil
    ) async throws -> TaskInfo {
        let inputURLs = request.inputURLs ?? []
        let model: KieModel = inputURLs.isEmpty ? .gptImage2TextToImage : .gptImage2ImageToImage

        var input: [String: Any] = [
            "prompt": request.prompt,
            "aspect_ratio": request.aspectRatio
        ]

        if !inputURLs.isEmpty {
            input["input_urls"] = inputURLs.map { $0.absoluteString }
        }
        if let resolution = request.resolution {
            input["resolution"] = resolution
        }
        if let nsfwChecker = request.nsfwChecker {
            input["nsfw_checker"] = nsfwChecker
        }

        #if DEBUG
        let debugBody: [String: Any] = [
            "model": model.rawValue,
            "input": input
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: debugBody, options: [.withoutEscapingSlashes]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🔍 KieAIKit Request Body:")
            print(jsonString)
        }
        #endif

        var body: [String: AnyCodable] = [
            "model": AnyCodable(model.rawValue),
            "input": AnyCodable(input)
        ]
        if let callBackUrl = callBackUrl {
            body["callBackUrl"] = AnyCodable(callBackUrl.absoluteString)
        }

        let apiRequest = APIRequest(
            path: "jobs/createTask",
            method: .post,
            body: body
        )

        let taskResponse = try await apiClient.performAndUnwrap(apiRequest, as: TaskCreationResponse.self)
        let taskInfo = TaskInfo(id: taskResponse.taskId, status: .pending)
        try taskInfo.validate()
        return taskInfo
    }

    /// Generates or edits an image using GPT Image 2 and waits for completion.
    ///
    /// - Parameters:
    ///   - request: The GPT Image 2 request parameters
    ///   - callBackUrl: Optional URL to receive task completion notifications
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The image generation result
    /// - Throws: An APIError if generation or polling fails
    public func gptImage2AndWait(
        request: GPTImage2Request,
        callBackUrl: URL? = nil,
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        let task = try await gptImage2(request: request, callBackUrl: callBackUrl)
        return try await waitForResult(task: task, timeout: timeout)
    }

    // MARK: - Nano Banana Pro

    /// Generates an image using Nano Banana Pro model.
    ///
    /// This method initiates an asynchronous image generation task and returns
    /// immediately with a task ID. Use the returned task info with `waitForResult`
    /// to poll for completion.
    ///
    /// - Parameters:
    ///   - request: The Nano Banana Pro request parameters
    ///   - callBackUrl: Optional URL to receive task completion notifications
    /// - Returns: A TaskInfo containing the task ID
    /// - Throws: An APIError if the request fails
    public func nanoBananaPro(
        request: NanoBananaProRequest,
        callBackUrl: URL? = nil
    ) async throws -> TaskInfo {
        // Build the request body for Nano Banana Pro
        var input: [String: Any] = [
            "prompt": request.prompt,
            "aspect_ratio": request.aspectRatio,
            "resolution": request.resolution,
            "output_format": request.outputFormat
        ]

        // Only include image_input when provided (image-to-image mode)
        if let imageInput = request.imageInput, !imageInput.isEmpty {
            input["image_input"] = imageInput.map { $0.absoluteString }
        }

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
        let debugBody = DebugBody(model: KieModel.nanoBananaPro.rawValue, input: input)
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
            let callBackUrl: String?

            init(model: String, input: [String: Any], callBackUrl: String? = nil) {
                self.model = model
                self.input = input.mapValues { AnyCodable($0) }
                self.callBackUrl = callBackUrl
            }
        }

        let body = DynamicBody(
            model: KieModel.nanoBananaPro.rawValue,
            input: input,
            callBackUrl: callBackUrl?.absoluteString
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

    /// Generates an image using Nano Banana Pro and waits for completion.
    ///
    /// This is a convenience method that combines `nanoBananaPro` and `waitForResult`.
    ///
    /// - Parameters:
    ///   - request: The Nano Banana Pro request parameters
    ///   - callBackUrl: Optional URL to receive task completion notifications
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The image generation result
    /// - Throws: An APIError if generation or polling fails
    public func nanoBananaProAndWait(
        request: NanoBananaProRequest,
        callBackUrl: URL? = nil,
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        let task = try await nanoBananaPro(request: request, callBackUrl: callBackUrl)
        return try await waitForResult(task: task, timeout: timeout)
    }

    // MARK: - Nano Banana 2

    /// Generates an image using Nano Banana 2 model.
    ///
    /// This method initiates an asynchronous image generation task and returns
    /// immediately with a task ID. Use the returned task info with `waitForResult`
    /// to poll for completion.
    ///
    /// - Parameters:
    ///   - request: The Nano Banana 2 request parameters
    ///   - callBackUrl: Optional URL to receive task completion notifications
    /// - Returns: A TaskInfo containing the task ID
    /// - Throws: An APIError if the request fails
    public func nanoBanana2(
        request: NanoBanana2Request,
        callBackUrl: URL? = nil
    ) async throws -> TaskInfo {
        // Build the request body for Nano Banana 2
        var input: [String: Any] = [
            "prompt": request.prompt,
            "aspect_ratio": request.aspectRatio,
            "resolution": request.resolution,
            "output_format": request.outputFormat
        ]

        // Only include image_input when provided (image-to-image mode)
        if let imageInput = request.imageInput, !imageInput.isEmpty {
            input["image_input"] = imageInput.map { $0.absoluteString }
        }

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
        let debugBody = DebugBody(model: KieModel.nanoBanana2.rawValue, input: input)
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
            let callBackUrl: String?

            init(model: String, input: [String: Any], callBackUrl: String? = nil) {
                self.model = model
                self.input = input.mapValues { AnyCodable($0) }
                self.callBackUrl = callBackUrl
            }
        }

        let body = DynamicBody(
            model: KieModel.nanoBanana2.rawValue,
            input: input,
            callBackUrl: callBackUrl?.absoluteString
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

    /// Generates an image using Nano Banana 2 and waits for completion.
    ///
    /// This is a convenience method that combines `nanoBanana2` and `waitForResult`.
    ///
    /// - Parameters:
    ///   - request: The Nano Banana 2 request parameters
    ///   - callBackUrl: Optional URL to receive task completion notifications
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The image generation result
    /// - Throws: An APIError if generation or polling fails
    public func nanoBanana2AndWait(
        request: NanoBanana2Request,
        callBackUrl: URL? = nil,
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        let task = try await nanoBanana2(request: request, callBackUrl: callBackUrl)
        return try await waitForResult(task: task, timeout: timeout)
    }
}
