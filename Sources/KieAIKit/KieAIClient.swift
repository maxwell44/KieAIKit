//
//  KieAIClient.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// The main entry point for interacting with the Kie.ai API.
///
/// This client provides access to image, video, and audio generation services
/// through a clean, strongly-typed Swift interface.
///
/// **Example:**
/// ```swift
/// let client = KieAIClient(apiKey: "YOUR_API_KEY")
///
/// // Generate an image
/// let task = try await client.image.generate(
///     model: .gptImage15,
///     prompt: "A cyberpunk city at night"
/// )
///
/// let result = try await client.image.waitForResult(task)
/// print("Image URL: \(result.primaryImageURL)")
/// ```
public final class KieAIClient {

    /// The configuration for this client.
    public let configuration: Configuration

    /// The internal API client.
    private let apiClient: APIClient

    /// Service for image generation.
    public var image: ImageService {
        return ImageService(apiClient: apiClient)
    }

    /// Service for video generation.
    public var video: VideoService {
        return VideoService(apiClient: apiClient)
    }

    /// Service for audio generation.
    public var audio: AudioService {
        return AudioService(apiClient: apiClient)
    }

    /// Service for file upload.
    public var upload: FileUploadService {
        return FileUploadService(apiClient: apiClient)
    }

    /// Creates a new Kie.ai client with the specified API key.
    ///
    /// - Parameter apiKey: Your Kie.ai API key
    /// - Parameter baseURL: Optional custom base URL (defaults to official API)
    /// - Parameter timeout: Optional request timeout in seconds (defaults to 60)
    public convenience init(
        apiKey: String,
        baseURL: String? = nil,
        timeout: TimeInterval = 60.0
    ) {
        let config: Configuration
        if let baseURL = baseURL {
            config = Configuration(apiKey: apiKey, baseURL: baseURL, timeout: timeout)
        } else {
            config = Configuration(apiKey: apiKey, timeout: timeout)
        }
        self.init(configuration: config)
    }

    /// Creates a new Kie.ai client with a configuration object.
    ///
    /// Use this initializer when you need more control over configuration,
    /// such as setting a custom base URL.
    ///
    /// - Parameter configuration: The configuration to use
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.apiClient = APIClient(configuration: configuration)
    }

    // MARK: - Convenience Methods for Common Operations

    /// Generates an image and waits for completion in one call.
    ///
    /// This is a convenience method that creates a request and waits for the result.
    ///
    /// - Parameters:
    ///   - model: The AI model to use
    ///   - prompt: The text prompt describing the image
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The image generation result
    /// - Throws: An APIError if generation fails
    public func generateImage(
        model: KieModel,
        prompt: String,
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        let request = ImageGenerationRequest(prompt: prompt)
        return try await image.generateAndWait(model: model, request: request, timeout: timeout)
    }

    /// Generates a video and waits for completion in one call.
    ///
    /// This is a convenience method that creates a request and waits for the result.
    ///
    /// - Parameters:
    ///   - model: The AI model to use
    ///   - prompt: The text prompt describing the video
    ///   - duration: Duration of the video in seconds (default: 5)
    ///   - timeout: Maximum time to wait before timing out (default: 600 seconds)
    /// - Returns: The video generation result
    /// - Throws: An APIError if generation fails
    public func generateVideo(
        model: KieModel,
        prompt: String,
        duration: Int = 5,
        timeout: TimeInterval = 600.0
    ) async throws -> VideoGenerationResult {
        let request = VideoGenerationRequest.with(
            prompt: prompt,
            duration: duration
        )
        return try await video.generateAndWait(model: model, request: request, timeout: timeout)
    }

    /// Generates audio and waits for completion in one call.
    ///
    /// This is a convenience method that creates a request and waits for the result.
    ///
    /// - Parameters:
    ///   - model: The AI model to use
    ///   - prompt: The text prompt describing the audio
    ///   - duration: Duration of the audio in seconds (default: 30)
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds)
    /// - Returns: The audio generation result
    /// - Throws: An APIError if generation fails
    public func generateAudio(
        model: KieModel,
        prompt: String,
        duration: Double = 30.0,
        timeout: TimeInterval = 300.0
    ) async throws -> AudioGenerationResult {
        let request = AudioGenerationRequest.with(
            prompt: prompt,
            duration: duration
        )
        return try await audio.generateAndWait(model: model, request: request, timeout: timeout)
    }

    // MARK: - File Upload Convenience

    /// Uploads image data and returns the URL.
    ///
    /// Convenience method for uploading images for use with image editing models.
    ///
    /// - Parameters:
    ///   - data: Image data
    ///   - fileName: Optional filename
    /// - Returns: URL of the uploaded image
    /// - Throws: An APIError if upload fails
    public func uploadImage(
        _ data: Data,
        fileName: String? = nil
    ) async throws -> URL {
        let uploadedFile = try await upload.uploadData(data, uploadPath: "images", fileName: fileName)
        return uploadedFile.fileURL
    }

    /// Uploads an image from a URL.
    ///
    /// - Parameters:
    ///   - url: Remote image URL
    ///   - fileName: Optional filename
    /// - Returns: URL of the uploaded image
    /// - Throws: An APIError if upload fails
    public func uploadImageFromURL(
        _ url: URL,
        fileName: String? = nil
    ) async throws -> URL {
        let uploadedFile = try await upload.uploadFromURL(url, uploadPath: "images", fileName: fileName)
        return uploadedFile.fileURL
    }

    /// Edits an image with local data - upload + edit in one call.
    ///
    /// This convenience method uploads the image data and then submits the edit request.
    ///
    /// - Parameters:
    ///   - imageData: Local image data to upload and edit
    ///   - prompt: Edit prompt
    ///   - outputFormat: Output format (png, jpg, webp)
    ///   - imageSize: Image size (1:1, 16:9, etc.)
    ///   - timeout: Maximum wait time
    /// - Returns: Edited image result
    /// - Throws: An APIError if upload or edit fails
    public func editImage(
        _ imageData: Data,
        prompt: String,
        outputFormat: String = "png",
        imageSize: String = "1:1",
        timeout: TimeInterval = 300.0
    ) async throws -> ImageGenerationResult {
        // Step 1: Upload the image
        let imageURL = try await uploadImage(imageData)

        // Step 2: Create edit request
        let request = ImageEditRequest.with(
            prompt: prompt,
            imageURL: imageURL,
            outputFormat: outputFormat,
            imageSize: imageSize
        )

        // Step 3: Submit edit task
        return try await image.editAndWait(
            model: .googleNanoBananaEdit,
            request: request,
            timeout: timeout
        )
    }
}

// MARK: - Task Polling Convenience

extension KieAIClient {

    /// Waits for a task to complete and returns the appropriate result type.
    ///
    /// This generic method can wait for any task and return the result.
    ///
    /// - Parameters:
    ///   - task: The task to wait for
    ///   - timeout: Maximum time to wait before timing out
    /// - Returns: The generation result
    /// - Throws: An APIError if polling fails or times out
    public func waitForResult<T: GenerationResult>(
        task: TaskInfo,
        timeout: TimeInterval = 300.0
    ) async throws -> T {
        switch task.contentType {
        case .image:
            let result = try await image.waitForResult(task: task, timeout: timeout)
            return result as! T
        case .video:
            let result = try await video.waitForResult(task: task, timeout: timeout)
            return result as! T
        case .audio:
            let result = try await audio.waitForResult(task: task, timeout: timeout)
            return result as! T
        case .none:
            throw APIError.unknown(NSError(domain: "KieAIKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown content type"]))
        }
    }
}

/// Protocol for generation result types.
public protocol GenerationResult {}
extension ImageGenerationResult: GenerationResult {}
extension VideoGenerationResult: GenerationResult {}
extension AudioGenerationResult: GenerationResult {}
