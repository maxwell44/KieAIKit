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
        struct JobRequestBody: Codable {
            let model: String
            let input: VideoInput

            struct VideoInput: Codable {
                let prompt: String
                let negativePrompt: String?
                let duration: Int?
                let aspectRatio: String?
                let fps: Int?
                let seed: Int?
                let initImageURL: URL?

                enum CodingKeys: String, CodingKey {
                    case prompt
                    case negativePrompt = "negative_prompt"
                    case duration
                    case aspectRatio = "aspect_ratio"
                    case fps
                    case seed
                    case initImageURL = "init_image_url"
                }
            }
        }

        let body = JobRequestBody(
            model: model.rawValue,
            input: JobRequestBody.VideoInput(
                prompt: request.prompt,
                negativePrompt: request.negativePrompt,
                duration: request.duration,
                aspectRatio: request.aspectRatio?.rawValue,
                fps: request.fps,
                seed: request.seed,
                initImageURL: request.initImageURL
            )
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

        return VideoGenerationResult(
            taskId: finalTaskInfo.id,
            videoURL: resultURL,
            model: finalTaskInfo.model ?? "unknown",
            prompt: "",  // Prompt not returned in task status
            duration: finalTaskInfo.metadata?["duration"] != nil ? Double(finalTaskInfo.metadata!["duration"]!) : nil,
            metadata: finalTaskInfo.metadata
        )
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

// MARK: - Veo 3.1 Support

extension VideoService {

    /// Generates a video using Veo 3.1 API.
    ///
    /// This method uses the dedicated Veo 3.1 endpoint which supports:
    /// - Text-to-video (TEXT_2_VIDEO)
    /// - Image-to-video (FIRST_AND_LAST_FRAMES_2_VIDEO)
    /// - Reference-based generation (REFERENCE_2_VIDEO)
    ///
    /// - Parameters:
    ///   - request: The Veo 3.1 generation request
    ///   - timeout: Maximum time to wait before timing out (default: 600 seconds)
    /// - Returns: The video generation result
    /// - Throws: An APIError if generation or polling fails
    public func generateVeo31(
        request: Veo31Request,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        print("🔍 [VideoService] Veo 3.1 Request:")
        print("   Path: jobs/createTask")
        print("   Model: veo-3.1/\(request.mode == .text2Video ? "text-to-video" : "image-to-video")")
        print("   Prompt: \(String(request.prompt.prefix(100)))...")

        // Use standard job creation format
        struct JobRequestBody: Codable {
            let model: String
            let input: Veo31Input

            struct Veo31Input: Codable {
                let prompt: String
                let imageUrls: [URL]?
                let negativePrompt: String?
                let duration: Int?
                let aspectRatio: String?
                let fps: Int?
                let seed: Int?

                enum CodingKeys: String, CodingKey {
                    case prompt
                    case imageUrls = "imageUrls"
                    case negativePrompt = "negative_prompt"
                    case duration
                    case aspectRatio = "aspect_ratio"
                    case fps
                    case seed
                }
            }

            init(from request: Veo31Request) {
                self.model = "veo-3.1/" + (request.mode == .text2Video ? "text-to-video" : "image-to-video")
                self.input = Veo31Input(
                    prompt: request.prompt,
                    imageUrls: request.imageUrls,
                    negativePrompt: nil,
                    duration: nil,
                    aspectRatio: request.aspectRatio?.rawValue,
                    fps: nil,
                    seed: request.seed
                )
            }
        }

        let jobBody = JobRequestBody(from: request)
        let apiRequest = APIRequest(
            path: "jobs/createTask",
            method: .post,
            body: jobBody
        )

        // Use standard task creation response
        let taskResponse = try await apiClient.performAndUnwrap(apiRequest, as: TaskCreationResponse.self)

        print("✅ [VideoService] Task created: \(taskResponse.taskId)")

        // Poll for completion
        let finalTaskInfo = try await poller.poll(
            taskId: taskResponse.taskId,
            endpoint: "jobs/recordInfo?taskId",
            interval: 2.0,
            timeout: timeout
        )

        print("✅ [VideoService] Task completed")
        print("   Status: \(finalTaskInfo.status)")
        print("   Result URL: \(finalTaskInfo.resultURL?.absoluteString ?? "nil")")

        guard let resultURL = finalTaskInfo.resultURL else {
            throw APIError.serverError("Task completed but no result URL provided")
        }

        return VideoGenerationResult(
            taskId: finalTaskInfo.id,
            videoURL: resultURL,
            model: jobBody.model,
            prompt: request.prompt,
            duration: finalTaskInfo.metadata?["duration"] != nil ? Double(finalTaskInfo.metadata!["duration"]!) : nil,
            metadata: finalTaskInfo.metadata
        )
    }

        // Check for immediate success or task creation
        guard response.isSuccess else {
            throw APIError.serverError("Veo 3.1 generation failed: \(response.message)")
        }

        guard let data = response.data else {
            throw APIError.serverError("No data returned in Veo 3.1 response")
        }

        // If video URL is immediately available, return it
        if let videoUrl = data.videoUrl {
            return VideoGenerationResult(
                taskId: data.taskId,
                videoURL: videoUrl,
                model: request.model.rawValue,
                prompt: request.prompt,
                duration: nil,
                metadata: nil
            )
        }

        // Otherwise, poll for task completion
        let taskInfo = TaskInfo(id: data.taskId, status: .pending)
        let finalTaskInfo = try await poller.poll(
            taskId: taskInfo.id,
            endpoint: "jobs/recordInfo?taskId",
            interval: 2.0,
            timeout: timeout
        )

        guard let resultURL = finalTaskInfo.resultURL else {
            throw APIError.serverError("Task completed but no result URL provided")
        }

        return VideoGenerationResult(
            taskId: finalTaskInfo.id,
            videoURL: resultURL,
            model: finalTaskInfo.model ?? request.model.rawValue,
            prompt: request.prompt,
            duration: finalTaskInfo.metadata?["duration"] != nil ? Double(finalTaskInfo.metadata!["duration"]!) : nil,
            metadata: finalTaskInfo.metadata
        )
    }

    /// Generates a video using Veo 3.1 and waits for completion.
    ///
    /// Convenience method for text-to-video generation.
    ///
    /// - Parameters:
    ///   - prompt: Text prompt describing the video
    ///   - model: Veo model variant (default: veo3_fast)
    ///   - aspectRatio: Video aspect ratio (default: 16:9)
    ///   - timeout: Maximum time to wait (default: 600 seconds)
    /// - Returns: The video generation result
    /// - Throws: An APIError if generation fails
    public func generateVeo31TextToVideo(
        prompt: String,
        model: Veo31Request.VeoModel = .veo3_fast,
        aspectRatio: Veo31Request.AspectRatio = .landscape,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        let request = Veo31Request.textToVideo(
            prompt: prompt,
            model: model,
            aspectRatio: aspectRatio
        )
        return try await generateVeo31(request: request, timeout: timeout)
    }

    /// Generates a video from an image using Veo 3.1.
    ///
    /// - Parameters:
    ///   - prompt: Text prompt describing the video
    ///   - imageUrl: URL of the reference image
    ///   - model: Veo model variant (default: veo3_fast)
    ///   - aspectRatio: Video aspect ratio (default: auto)
    ///   - timeout: Maximum time to wait (default: 600 seconds)
    /// - Returns: The video generation result
    /// - Throws: An APIError if generation fails
    public func generateVeo31ImageToVideo(
        prompt: String,
        imageUrl: URL,
        model: Veo31Request.VeoModel = .veo3_fast,
        aspectRatio: Veo31Request.AspectRatio = .auto,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        let request = Veo31Request.imageToVideo(
            prompt: prompt,
            imageUrl: imageUrl,
            model: model,
            aspectRatio: aspectRatio
        )
        return try await generateVeo31(request: request, timeout: timeout)
    }

    /// Generates a video from first and last frames using Veo 3.1.
    ///
    /// - Parameters:
    ///   - prompt: Text prompt describing the transition
    ///   - firstFrameUrl: URL of the first frame
    ///   - lastFrameUrl: URL of the last frame
    ///   - model: Veo model variant (default: veo3_fast)
    ///   - aspectRatio: Video aspect ratio (default: 16:9)
    ///   - timeout: Maximum time to wait (default: 600 seconds)
    /// - Returns: The video generation result
    /// - Throws: An APIError if generation fails
    public func generateVeo31FirstAndLastFrames(
        prompt: String,
        firstFrameUrl: URL,
        lastFrameUrl: URL,
        model: Veo31Request.VeoModel = .veo3_fast,
        aspectRatio: Veo31Request.AspectRatio = .landscape,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        let request = Veo31Request.firstAndLastFramesToVideo(
            prompt: prompt,
            firstFrameUrl: firstFrameUrl,
            lastFrameUrl: lastFrameUrl,
            model: model,
            aspectRatio: aspectRatio
        )
        return try await generateVeo31(request: request, timeout: timeout)
    }
}

// MARK: - Extensions for Custom Model Support

extension VideoService {

    /// Generates a video using a custom model identifier string.
    ///
    /// Use this for models that are not yet in the KieModel enum.
    ///
    /// - Parameters:
    ///   - modelString: The model identifier (e.g., "veo-3.1/text-to-video")
    ///   - request: The generation request parameters
    ///   - timeout: Maximum time to wait before timing out (default: 600 seconds)
    /// - Returns: The video generation result
    /// - Throws: An APIError if generation or polling fails
    public func generateAndWait(
        modelString: String,
        request: VideoGenerationRequest,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        struct JobRequestBody: Codable {
            let model: String
            let input: VideoInput

            struct VideoInput: Codable {
                let prompt: String
                let negativePrompt: String?
                let duration: Int?
                let aspectRatio: String?
                let fps: Int?
                let seed: Int?
                let initImageURL: URL?

                enum CodingKeys: String, CodingKey {
                    case prompt
                    case negativePrompt = "negative_prompt"
                    case duration
                    case aspectRatio = "aspect_ratio"
                    case fps
                    case seed
                    case initImageURL = "init_image_url"
                }
            }
        }

        let body = JobRequestBody(
            model: modelString,
            input: JobRequestBody.VideoInput(
                prompt: request.prompt,
                negativePrompt: request.negativePrompt,
                duration: request.duration,
                aspectRatio: request.aspectRatio?.rawValue,
                fps: request.fps,
                seed: request.seed,
                initImageURL: request.initImageURL
            )
        )

        let apiRequest = APIRequest(
            path: "jobs/createTask",
            method: .post,
            body: body
        )

        // Create task
        let taskResponse = try await apiClient.performAndUnwrap(apiRequest, as: TaskCreationResponse.self)
        let taskInfo = TaskInfo(id: taskResponse.taskId, status: .pending)
        try taskInfo.validate()

        // Wait for result
        let finalTaskInfo = try await poller.poll(
            taskId: taskInfo.id,
            endpoint: "jobs/recordInfo?taskId",
            interval: 2.0,
            timeout: timeout
        )

        guard let resultURL = finalTaskInfo.resultURL else {
            throw APIError.serverError("Task completed but no result URL provided")
        }

        return VideoGenerationResult(
            taskId: finalTaskInfo.id,
            videoURL: resultURL,
            model: finalTaskInfo.model ?? modelString,
            prompt: "",
            duration: finalTaskInfo.metadata?["duration"] != nil ? Double(finalTaskInfo.metadata!["duration"]!) : nil,
            metadata: finalTaskInfo.metadata
        )
    }
}
