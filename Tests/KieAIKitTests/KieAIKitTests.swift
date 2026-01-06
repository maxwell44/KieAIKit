//
//  KieAIKitTests.swift
//  KieAIKitTests
//
//  Created for the Kie.ai community SDK.
//

import XCTest
@testable import KieAIKit

final class KieAIKitTests: XCTestCase {

    // MARK: - Configuration Tests

    func testConfigurationInitialization() {
        let config = Configuration(
            apiKey: "test-api-key",
            baseURL: "https://api.example.com",
            timeout: 120.0
        )

        XCTAssertEqual(config.apiKey, "test-api-key")
        XCTAssertEqual(config.baseURL, "https://api.example.com")
        XCTAssertEqual(config.timeout, 120.0)
    }

    func testConfigurationDefaults() {
        let config = Configuration(apiKey: "test-api-key")

        XCTAssertEqual(config.baseURL, "https://api.kie.ai/api/v1")
        XCTAssertEqual(config.timeout, 60.0)
    }

    // MARK: - KieModel Tests

    func testKieModelRawValues() {
        XCTAssertEqual(KieModel.gptImage15.rawValue, "gpt-image-1.5")
        XCTAssertEqual(KieModel.seedream45.rawValue, "seedream-4.5")
        XCTAssertEqual(KieModel.flux2.rawValue, "flux-2")
        XCTAssertEqual(KieModel.kling26.rawValue, "kling-2.6")
        XCTAssertEqual(KieModel.wan26.rawValue, "wan-2.6")
    }

    func testKieModelCategories() {
        XCTAssertTrue(KieModel.allImageModels.contains(.gptImage15))
        XCTAssertTrue(KieModel.allVideoModels.contains(.kling26))
    }

    func testKieModelCodable() {
        let model = KieModel.flux2
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        do {
            let data = try encoder.encode(model)
            let decoded = try decoder.decode(KieModel.self, from: data)
            XCTAssertEqual(decoded, .flux2)
        } catch {
            XCTFail("Failed to encode/decode KieModel: \(error)")
        }
    }

    // MARK: - TaskStatus Tests

    func testTaskStatusProperties() {
        XCTAssertTrue(TaskStatus.success.isTerminal)
        XCTAssertTrue(TaskStatus.failed.isTerminal)
        XCTAssertTrue(TaskStatus.cancelled.isTerminal)
        XCTAssertFalse(TaskStatus.pending.isTerminal)
        XCTAssertFalse(TaskStatus.processing.isTerminal)

        XCTAssertTrue(TaskStatus.success.isSuccess)
        XCTAssertTrue(TaskStatus.failed.isFailed)
        XCTAssertFalse(TaskStatus.success.isFailed)
    }

    // MARK: - Request Tests

    func testImageGenerationRequestDefaults() {
        let request = ImageGenerationRequest(prompt: "A cat")

        XCTAssertEqual(request.prompt, "A cat")
        XCTAssertNil(request.negativePrompt)
        XCTAssertNil(request.width)
        XCTAssertNil(request.height)
        XCTAssertNil(request.count)
    }

    func testImageGenerationRequestWithSize() {
        let request = ImageGenerationRequest.with(
            prompt: "A dog",
            size: ImageGenerationRequest.ImageSize.landscape,
            negativePrompt: "blurry"
        )

        XCTAssertEqual(request.prompt, "A dog")
        XCTAssertEqual(request.width, 1920)
        XCTAssertEqual(request.height, 1080)
        XCTAssertEqual(request.negativePrompt, "blurry")
    }

    func testVideoGenerationRequestDefaults() {
        let request = VideoGenerationRequest.with(
            prompt: "A running cat",
            duration: 5
        )

        XCTAssertEqual(request.prompt, "A running cat")
        XCTAssertEqual(request.duration, 5)
        XCTAssertEqual(request.aspectRatio, .landscape)
    }

    func testVideoGenerationRequestImageToVideo() {
        let imageURL = URL(string: "https://example.com/image.jpg")!
        let request = VideoGenerationRequest.imageToVideo(
            prompt: "Animate this",
            initImageURL: imageURL,
            duration: 10
        )

        XCTAssertEqual(request.prompt, "Animate this")
        XCTAssertEqual(request.initImageURL, imageURL)
        XCTAssertEqual(request.duration, 10)
    }

    func testVideoGenerationAspectRatio() {
        XCTAssertEqual(VideoGenerationRequest.AspectRatio.landscape.rawValue, "16:9")
        XCTAssertEqual(VideoGenerationRequest.AspectRatio.portrait.rawValue, "9:16")
        XCTAssertEqual(VideoGenerationRequest.AspectRatio.square.rawValue, "1:1")
        XCTAssertEqual(VideoGenerationRequest.AspectRatio.cinematic.rawValue, "21:9")
    }

    func testAudioGenerationRequestDefaults() {
        let request = AudioGenerationRequest.with(
            prompt: "Calm music",
            duration: 30.0
        )

        XCTAssertEqual(request.prompt, "Calm music")
        XCTAssertEqual(request.duration, 30.0)
        XCTAssertEqual(request.audioType, .music)
    }

    // MARK: - APIError Tests

    func testAPIErrorDescription() {
        let error = APIError.invalidURL("https://bad-url")
        XCTAssertNotNil(error.errorDescription)

        let timeoutError = APIError.timeout
        XCTAssertEqual(timeoutError.errorDescription, "Request timed out")
    }

    func testAPIErrorFromStatusCode() {
        let unauthorizedError = APIError.from(
            response: HTTPURLResponse(url: URL(string: "https://api.example.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!,
            data: nil
        )
        if case .unauthorized = unauthorizedError {
            // Success
        } else {
            XCTFail("Expected unauthorized error")
        }
    }

    // MARK: - Client Tests

    func testClientInitialization() {
        let client = KieAIClient(apiKey: "test-key")

        XCTAssertEqual(client.configuration.apiKey, "test-key")
        XCTAssertEqual(client.configuration.baseURL, "https://api.kie.ai/api/v1")
    }

    func testClientWithCustomBaseURL() {
        let client = KieAIClient(
            apiKey: "test-key",
            baseURL: "https://custom.api.com"
        )

        XCTAssertEqual(client.configuration.baseURL, "https://custom.api.com")
    }

    func testClientWithConfiguration() {
        let config = Configuration(
            apiKey: "test-key",
            baseURL: "https://custom.api.com",
            timeout: 120.0
        )
        let client = KieAIClient(configuration: config)

        XCTAssertEqual(client.configuration.apiKey, "test-key")
        XCTAssertEqual(client.configuration.baseURL, "https://custom.api.com")
        XCTAssertEqual(client.configuration.timeout, 120.0)
    }

    // MARK: - Model Serialization Tests

    func testImageGenerationRequestCodable() {
        let request = ImageGenerationRequest(
            prompt: "Test prompt",
            negativePrompt: "bad quality",
            count: 2,
            width: 1024,
            height: 1024,
            seed: 42
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            let data = try encoder.encode(request)
            let jsonString = String(data: data, encoding: .utf8)!
            XCTAssertTrue(jsonString.contains("prompt"))
            XCTAssertTrue(jsonString.contains("negative_prompt"))
        } catch {
            XCTFail("Failed to encode request: \(error)")
        }
    }
}
