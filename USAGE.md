# KieAIKit 使用指南

## 1. 在 Xcode 项目中添加 KieAIKit

### 步骤：
1. 打开你的 Xcode 项目
2. 选择 File → Add Package Dependencies...
3. 输入本地路径：`/Users/maxwellyu/CC/KieAIKit`
4. 点击 "Add Package"
5. 选择 KieAIKit 库，添加到你的 target

## 2. 基本使用

### 导入框架
```swift
import KieAIKit
```

### 初始化客户端
```swift
// 使用你的 API Key
let client = KieAIClient(apiKey: "你的Kie.ai_API密钥")
```

### 生成图片
```swift
// 方式1：简单调用
do {
    let result = try await client.generateImage(
        model: .gptImage15,
        prompt: "一只在雪地里奔跑的猫"
    )
    print("图片URL: \(result.primaryImageURL!)")
} catch {
    print("错误: \(error)")
}

// 方式2：详细控制
let request = ImageGenerationRequest.with(
    prompt: "赛博朋克城市夜景",
    size: .landscape,
    negativePrompt: "模糊, 低质量"
)

let task = try await client.image.generate(model: .flux2, request: request)
let result = try await client.image.waitForResult(task: task)
```

### 生成视频
```swift
let result = try await client.generateVideo(
    model: .kling26,
    prompt: "一只猫在雪地里奔跑",
    duration: 5
)
print("视频URL: \(result.videoURL)")
```

### 生成音频
```swift
let result = try await client.generateAudio(
    model: .seedance15Pro,
    prompt: "宏大的管弦乐，戏剧性的渐强",
    duration: 30.0
)
print("音频URL: \(result.audioURL)")
```

## 3. 可用的模型

### 图片生成模型
- `KieModel.gptImage15` - GPT Image 1.5
- `KieModel.seedream45` - Seedream 4.5
- `KieModel.flux2` - Flux 2
- `KieModel.zImage` - Z-Image

### 视频生成模型
- `KieModel.kling26` - Kling 2.6
- `KieModel.wan26` - Wan 2.6
- `KieModel.seedance15Pro` - Seedance 1.5 Pro

## 4. 错误处理
```swift
do {
    let result = try await client.generateImage(model: .gptImage15, prompt: "...")
} catch let error as APIError {
    switch error {
    case .unauthorized:
        print("API Key 无效")
    case .timeout:
        print("请求超时")
    case .rateLimited:
        print("超出速率限制")
    case .taskFailed(let message):
        print("任务失败: \(message)")
    default:
        print("其他错误: \(error.localizedDescription)")
    }
}
```

## 5. 获取 API Key

1. 访问 [kie.ai](https://kie.ai) 注册账号
2. 在控制台获取你的 API Key
3. **重要**: 不要将 API Key 提交到版本控制系统

## 6. 注意事项

⚠️ **此 SDK 需要 Kie.ai 的真实 API 才能工作**

当前实现假设了以下 API 端点结构：
- 图片生成: `POST /images/generate`
- 视频生成: `POST /videos/generate`
- 音频生成: `POST /audio/generate`
- 任务状态: `GET /{type}/tasks/{task_id}`
- 获取结果: `GET /{type}/results/{task_id}`

如果实际 API 不同，需要相应调整 `Network/APIRequest.swift` 和 `Services/*.swift` 中的端点路径。
