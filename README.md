# KieAIKit

> **⚠️ Unofficial SDK**
> This is an unofficial, community-developed Swift SDK for the Kie.ai API. It is not officially endorsed or maintained by Kie.ai.

A type-safe, modern Swift SDK for interacting with the Kie.ai REST API. KieAIKit provides a clean interface for AI-powered image, video, and audio generation in your Swift applications.

## Features

- **Type-Safe Models**: Strongly-typed enums for available AI models - no more stringly-typed model names
- **Async/Await**: Modern Swift concurrency with async/await throughout
- **Task Polling**: Built-in polling mechanism for asynchronous generation tasks
- **Clean API**: Simple, expressive API that hides the complexity of HTTP and JSON
- **Debug Support**: Built-in request/response logging in DEBUG mode
- **No Dependencies**: Built on Foundation only - no third-party networking libraries
- **iOS & macOS**: Supports iOS 15+ and macOS 13+

## Installation

### Swift Package Manager

Add KieAIKit to your project in Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/maxwell44/KieAIKit`
3. Select the version rules
4. Add KieAIKit to your app target

Or manually add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/maxwell44/KieAIKit", from: "1.0.0")
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

⚠️ **Important**: Model names must match exactly what's listed in the [KIE Market](https://docs.kie.ai/market). Do NOT use model names from official sources (OpenAI, Anthropic, etc.) as KIE uses its own naming convention.

#### Verified Models

```swift
// Image Models
KieModel.gptImage15      // "gpt-image/1.5-text-to-image"
KieModel.flux2Flex       // "flux-2/flex-text-to-image"

// Video Models
KieModel.kling26         // "kling-2.6/text-to-video"
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

let task = try await client.image.generate(model: .flux2Flex, request: request)
let result = try await client.image.waitForResult(task: task, timeout: 300.0)
```

### Model-Specific Input Formats

Different models may require different input formats. The SDK handles this automatically:

- **GPT Image 1.5**: Requires `aspect_ratio` (string) and `quality` (string)
- **Flux-2**: Requires `aspect_ratio` (string) and `resolution` (string)

```swift
// GPT Image example
let result1 = try await client.generateImage(
    model: .gptImage15,
    prompt: "A beautiful landscape",
    width: 1024,
    height: 1024
)

// Flux-2 example
let result2 = try await client.generateImage(
    model: .flux2Flex,
    prompt: "A portrait of a cat",
    width: 1024,
    height: 1024
)
```

## Debugging

In DEBUG mode, the SDK automatically logs:

1. **Request URL** - The full API endpoint being called
2. **Request Body** - The JSON payload being sent
3. **Raw Response** - The raw JSON response from the API

Example debug output:
```
🔍 KieAIKit URL: https://api.kie.ai/api/v1/jobs/createTask
🔍 KieAIKit Request Body: {"model":"flux-2/flex-text-to-image","input":{...}}
🧾 KieAIKit Raw Response: {"code":200,"msg":"success","data":{...}}
```

This helps identify issues with:
- Incorrect model names
- Missing required fields
- API response format changes

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
    case .serverError(let message):
        print("Server error: \(message)")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

Common error codes:
- `401` - Unauthorized (invalid API key)
- `402` - Insufficient credits
- `404` - Resource not found (check model name)
- `422` - Validation error (check request parameters)
- `429` - Rate limit exceeded

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

Contributions are welcome! When adding new models:

1. **Verify the exact model name** from [KIE Market](https://docs.kie.ai/market)
2. **Check the required input format** in the model's documentation
3. **Add model-specific input handling** in `ImageService.buildInputForModel()` if needed
4. **Test with actual API calls** to ensure correctness

Please feel free to submit pull requests or open issues.

## Support

For issues specific to this SDK, please use the GitHub issue tracker.
For Kie.ai API issues, contact Kie.ai support directly.
