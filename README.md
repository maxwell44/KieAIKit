# KieAIKit

> **⚠️ Unofficial SDK**
> This is an unofficial, community-developed Swift SDK for the Kie.ai API. It is not officially endorsed or maintained by Kie.ai.

A type-safe, modern Swift SDK for interacting with the Kie.ai REST API. KieAIKit provides a clean interface for AI-powered image, video, and audio generation in your Swift applications.

## Features

- **Type-Safe Models**: Strongly-typed enums for available AI models - no more stringly-typed model names
- **Async/Await**: Modern Swift concurrency with async/await throughout
- **Task Polling**: Built-in polling mechanism for asynchronous generation tasks
- **Image Editing**: Support for image-to-image editing with Google Nano Banana models
- **File Upload**: Built-in file upload service for image/video editing workflows
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
    // GPT Image 2 text-to-image
    let result = try await client.generateGptImage2(
        prompt: "A cyberpunk city at night, neon lights, rain",
        aspectRatio: GPTImage2Request.AspectRatio.landscape,
        resolution: GPTImage2Request.Resolution.r2K
    )

    print("Image URL: \(result.primaryImageURL!)")

} catch {
    print("Error: \(error)")
}
```

For full control, use the image service directly:

```swift
let request = GPTImage2Request.textToImage(
    prompt: "A cinematic night city poster with neon reflections on a rainy street.",
    aspectRatio: GPTImage2Request.AspectRatio.auto
)

let task = try await client.image.gptImage2(request: request)
let result = try await client.image.waitForResult(task: task)
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

#### Image Editing

Edit existing images using AI-powered models:

```swift
do {
    // Using remote image URL (recommended)
    let imageURL = URL(string: "https://example.com/image.jpg")!

    let result = try await client.editGptImage2(
        prompt: "Change the background to a sunset beach",
        imageURLs: [imageURL],
        aspectRatio: GPTImage2Request.AspectRatio.landscape,
        resolution: GPTImage2Request.Resolution.r2K
    )

    print("Edited image URL: \(result.primaryImageURL!)")

} catch {
    print("Error: \(error)")
}
```

**Using Nano Banana Pro (Advanced Editing):**

```swift
do {
    let result = try await client.image.nanoBananaProAndWait(
        request: NanoBananaProRequest.with(
            prompt: "Comic poster: cool banana hero in shades",
            imageURL: imageURL,
            aspectRatio: "16:9",
            resolution: "2K",
            outputFormat: "png"
        ),
        timeout: 300.0
    )

    print("Generated image URL: \(result.primaryImageURL!)")

} catch {
    print("Error: \(error)")
}
```

**Uploading Local Images:**

```swift
do {
    // Upload local image and use it for editing
    let imageData = jpegData(compressionQuality: 0.9)

    let result = try await client.editImage(
        imageData,
        prompt: "Add a vintage film effect",
        outputFormat: "png",
        imageSize: "1:1",
        timeout: 300.0
    )

    print("Edited image URL: \(result.primaryImageURL!)")

} catch {
    print("Error: \(error)")
}
```

> **Note**: When uploading local images, ensure the file has a valid image extension (.jpg, .png, etc.) to avoid "file type not supported" errors. Using remote URLs is recommended.

## Best Practices

### Separating Task Creation from Waiting

For production apps, it's recommended to create the task and wait for results separately:

```swift
do {
    // Step 1: Create the task (returns immediately)
    let task = try await client.image.generate(
        model: .flux2Flex,
        request: ImageGenerationRequest(
            prompt: "一只在雪地里奔跑的猫，电影级画质"
        )
    )

    print("✅ 任务已创建，ID: \(task.id)")
    print("💡 可以保存任务ID，稍后查询结果")

    // Step 2: Wait for completion (optional - can be done later)
    let result = try await client.image.waitForResult(
        task: task,
        timeout: 120  // 120秒超时
    )

    print("✅ 图片生成成功!")
    print("   图片URL: \(result.primaryImageURL!)")

} catch let error as APIError {
    print("❌ API 错误: \(error)")
}
```

This approach allows you to:
- Save the task ID for later polling
- Handle long-running tasks without blocking
- Implement background task processing
- Show progress to users

### Handling Different Task States

The SDK properly handles all task states returned by the API:

- `waiting` - Task is queued and waiting to be processed
- `pending` - Task is pending (queued)
- `processing` - Task is currently being processed
- `success` - Task completed successfully
- `failed` - Task failed with an error
- `cancelled` - Task was cancelled

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

##### Text-to-Image Models

```swift
KieModel.gptImage15      // "gpt-image/1.5-text-to-image" - Immediate response
KieModel.gptImage2TextToImage  // "gpt-image-2-text-to-image" - Async task
KieModel.flux2Flex       // "flux-2/flex-text-to-image" - Async task
```

##### Image-to-Image / Image Editing Models

```swift
KieModel.gptImage2ImageToImage // "gpt-image-2-image-to-image" - GPT Image 2 editing
KieModel.googleNanoBananaEdit  // "google/nano-banana-edit" - Basic image editing
KieModel.nanoBananaPro         // "nano-banana-pro" - Advanced editing with resolution control
KieModel.nanoBanana2           // "nano-banana-2" - Advanced generation and editing
```

##### Text-to-Video Models

```swift
KieModel.kling26         // "kling-2.6/text-to-video" - Async task
```

#### Model Comparison

| Model | Type | Features | Execution |
|-------|------|----------|-----------|
| GPT Image 1.5 | Text-to-Image | Fast generation | Immediate |
| GPT Image 2 | Text-to-Image / Image-to-Image | Higher fidelity, text rendering, editing | Async |
| Flux-2 Flex | Text-to-Image | High quality | Async |
| Nano Banana Edit | Image-to-Image | Basic editing | Async |
| Nano Banana Pro | Image-to-Image | Advanced editing, resolution control | Async |
| Nano Banana 2 | Text-to-Image / Image-to-Image | Reference images, high resolution | Async |
| Kling 2.6 | Text-to-Video | Video generation | Async |

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
- **GPT Image 2**: Requires `prompt`, optional `input_urls`, `aspect_ratio`, `resolution`, `nsfw_checker`
- **Flux-2**: Requires `aspect_ratio` (string) and `resolution` (string)
- **Nano Banana Edit**: Requires `image_urls` and optional `output_format`, `image_size`
- **Nano Banana Pro**: Requires `prompt`, `aspect_ratio`, `resolution`, `output_format`, `image_input`

```swift
// GPT Image 2 text-to-image example
let result1 = try await client.generateGptImage2(
    prompt: "A beautiful landscape",
    aspectRatio: GPTImage2Request.AspectRatio.square,
    resolution: GPTImage2Request.Resolution.r1K
)

// Flux-2 example
let result2 = try await client.generateImage(
    model: .flux2Flex,
    prompt: "A portrait of a cat",
    width: 1024,
    height: 1024
)

// Nano Banana Edit example
let result3 = try await client.image.editAndWait(
    model: .googleNanoBananaEdit,
    request: ImageEditRequest.with(
        prompt: "Make it look like a watercolor painting",
        imageURL: imageURL
    )
)

// Nano Banana Pro example
let result4 = try await client.image.nanoBananaProAndWait(
    request: NanoBananaProRequest.with(
        prompt: "Comic poster style",
        imageURL: imageURL,
        aspectRatio: "16:9",
        resolution: "2K"
    )
)

// GPT Image 2 image-to-image example
let result5 = try await client.image.gptImage2AndWait(
    request: GPTImage2Request.imageToImage(
        prompt: "Turn this into a polished product hero image",
        imageURL: imageURL,
        aspectRatio: GPTImage2Request.AspectRatio.landscape,
        resolution: GPTImage2Request.Resolution.r2K
    )
)
```

#### Nano Banana Pro Parameters

Nano Banana Pro supports additional parameters for advanced control:

| Parameter | Values | Description |
|-----------|--------|-------------|
| `aspectRatio` | "1:1", "16:9", "9:16", "21:9" | Output aspect ratio |
| `resolution` | "1K", "2K", "4K" | Output resolution |
| `outputFormat` | "png", "jpg", "webp" | Output format |

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

## Changelog

### Latest Updates

#### Version 1.1.0
- ✨ Added `nano-banana-pro` model support
  - Advanced image editing with resolution control (1K, 2K, 4K)
  - Custom aspect ratios (1:1, 16:9, 9:16, 21:9)
  - Support for multi-image input
- ✨ Added `google/nano-banana-edit` model support
  - Basic image-to-image editing
  - Remote URL support
- ✨ Added file upload service
  - Upload from URL, Base64, or raw data
  - Automatic file handling with 3-day expiration
- 🐛 Fixed file upload response parsing to match actual API format
- 📝 Updated documentation with image editing examples

#### Version 1.0.0
- Initial release
- Text-to-image generation (GPT Image 1.5, Flux-2)
- Text-to-video generation (Kling 2.6)
- Task polling and result retrieval
- Debug logging support
