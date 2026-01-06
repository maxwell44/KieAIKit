# KieAIKit

> **⚠️ Unofficial SDK**
> This is an unofficial, community-developed Swift SDK for the Kie.ai API. It is not officially endorsed or maintained by Kie.ai.

A type-safe, modern Swift SDK for interacting with the Kie.ai REST API. KieAIKit provides a clean interface for AI-powered image, video, and audio generation in your Swift applications.

## Features

- **Type-Safe Models**: Strongly-typed enums for available AI models - no more stringly-typed model names
- **Async/Await**: Modern Swift concurrency with async/await throughout
- **Task Polling**: Built-in polling mechanism for asynchronous generation tasks
- **Clean API**: Simple, expressive API that hides the complexity of HTTP and JSON
- **No Dependencies**: Built on Foundation only - no third-party networking libraries
- **iOS & macOS**: Supports iOS 15+ and macOS 13+

## Installation

### Swift Package Manager

Add KieAIKit to your project in Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/your-username/KieAIKit`
3. Select the version rules
4. Add KieAIKit to your app target

Or manually add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/KieAIKit", from: "1.0.0")
]
```

## Quick Start

### 1. Get an API Key

Sign up at [kie.ai](https://kie.ai) to obtain your API key.

### 2. Initialize the Client

```swift
import KieAIKit

let client = KieAIClient(apiKey: "YOUR_API_KEY")
```

### 3. Generate Content

#### Image Generation

```swift
do {
    // Simple image generation
    let result = try await client.generateImage(
        model: .gptImage15,
        prompt: "A cyberpunk city at night, neon lights, rain"
    )

    print("Image URL: \(result.primaryImageURL!)")

    // Or with more control
    let request = ImageGenerationRequest.with(
        prompt: "A serene mountain landscape",
        size: .landscape,
        negativePrompt: "blurry, low quality"
    )

    let task = try await client.image.generate(model: .seedream45, request: request)
    let detailedResult = try await client.image.waitForResult(task: task)

} catch {
    print("Error: \(error)")
}
```

#### Video Generation

```swift
do {
    let result = try await client.generateVideo(
        model: .kling26,
        prompt: "A cat running through snow",
        duration: 5
    )

    print("Video URL: \(result.videoURL)")

} catch {
    print("Error: \(error)")
}
```

#### Audio Generation

```swift
do {
    let result = try await client.generateAudio(
        model: .seedance15Pro,
        prompt: "Epic orchestral music with dramatic crescendos",
        duration: 30.0
    )

    print("Audio URL: \(result.audioURL)")

} catch {
    print("Error: \(error)")
}
```

## Advanced Usage

### Custom Configuration

```swift
let config = Configuration(
    apiKey: "YOUR_API_KEY",
    baseURL: "https://api.kie.ai/api/v1",
    timeout: 120.0
)

let client = KieAIClient(configuration: config)
```

### Available Models

```swift
// Image Models
KieModel.gptImage15      // GPT Image 1.5
KieModel.seedream45      // Seedream 4.5
KieModel.flux2           // Flux 2
KieModel.zImage          // Z-Image

// Video Models
KieModel.kling26         // Kling 2.6
KieModel.wan26           // Wan 2.6
KieModel.seedance15Pro   // Seedance 1.5 Pro
```

### Detailed Request Configuration

```swift
let request = ImageGenerationRequest(
    prompt: "A futuristic cityscape",
    negativePrompt: "blurry, distorted",
    count: 2,
    width: 1920,
    height: 1080,
    seed: 42
)

let task = try await client.image.generate(model: .flux2, request: request)
let result = try await client.image.waitForResult(task: task, timeout: 300.0)
```

### Video with Custom Settings

```swift
let request = VideoGenerationRequest(
    prompt: "A serene beach at sunset",
    duration: 10,
    aspectRatio: .cinematic,
    fps: 30,
    seed: 100
)

let task = try await client.video.generate(model: .wan26, request: request)
let result = try await client.video.waitForResult(task: task)
```

## API Structure

The SDK is organized into several layers:

- **KieAIClient**: Main entry point with convenience methods
- **Services**: Specialized services for Image, Video, and Audio generation
- **Models**: Strongly-typed request/response models
- **Network**: Internal HTTP client and error handling

## Error Handling

All SDK methods throw `APIError` with meaningful error information:

```swift
do {
    let result = try await client.generateImage(model: .gptImage15, prompt: "...")
} catch let error as APIError {
    switch error {
    case .unauthorized:
        print("Invalid API key")
    case .timeout:
        print("Request timed out")
    case .taskFailed(let message):
        print("Task failed: \(message)")
    case .rateLimited:
        print("Rate limit exceeded")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## Security

- **Never** commit your API key to version control
- Use environment variables or secure storage for production apps
- Consider using `.fromEnvironment()` for development:

```swift
if let config = Configuration.fromEnvironment() {
    let client = KieAIClient(configuration: config)
} else {
    fatalError("KIE_AI_API_KEY environment variable not set")
}
```

## Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## License

This project is released under the MIT License.

## Disclaimer

This is an unofficial SDK and is not affiliated with, endorsed by, or sponsored by Kie.ai. The Kie.ai name and trademarks belong to their respective owners.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## Support

For issues specific to this SDK, please use the GitHub issue tracker.
For Kie.ai API issues, contact Kie.ai support directly.
