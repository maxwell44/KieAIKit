//
//  Main.swift
//  KieAIKit 示例代码
//
//  这是一个演示如何在 Swift 中使用 KieAIKit 的示例
//

import Foundation
import KieAIKit

@main
struct Main {
    static func main() async throws {
        // 1. 初始化客户端（替换成你的真实 API Key）
        let client = KieAIClient(apiKey: "你的API_KEY")

        // 2. 生成图片的示例
        print("=== 图片生成示例 ===")
        do {
            let result = try await client.generateImage(
                model: .gptImage15,
                prompt: "一只在雪地里奔跑的猫，电影级画质"
            )
            print("✅ 图片生成成功!")
            print("   任务ID: \(result.taskId)")
            print("   图片URL: \(result.primaryImageURL!)")
        } catch {
            print("❌ 错误: \(error)")
        }

        // 3. 生成视频的示例
        print("\n=== 视频生成示例 ===")
        do {
            let result = try await client.generateVideo(
                model: .kling26,
                prompt: "日落时分海滩上的海浪",
                duration: 5
            )
            print("✅ 视频生成成功!")
            print("   任务ID: \(result.taskId)")
            print("   视频URL: \(result.videoURL)")
        } catch {
            print("❌ 错误: \(error)")
        }

        // 4. 高级用法 - 自定义请求
        print("\n=== 高级用法示例 ===")
        let customRequest = ImageGenerationRequest(
            prompt: "赛博朋克城市夜景，霓虹灯，雨夜",
            negativePrompt: "模糊, 低质量, 变形",
            count: 2,
            width: 1920,
            height: 1080,
            seed: 42
        )

        do {
            let task = try await client.image.generate(model: .flux2Flex, request: customRequest)
            print("✅ 任务已创建，ID: \(task.id)")
            print("   状态: \(task.status)")

            // 等待结果
            let result = try await client.image.waitForResult(task: task, timeout: 300.0)
            print("✅ 生成完成!")
            print("   图片数量: \(result.imageUrls.count)")
        } catch {
            print("❌ 错误: \(error)")
        }

        // 5. 错误处理示例
        print("\n=== 错误处理示例 ===")
        do {
            let _ = try await client.generateImage(
                model: .gptImage15,
                prompt: "测试图片"
            )
        } catch let error as APIError {
            switch error {
            case .unauthorized:
                print("❌ API Key 无效，请检查你的密钥")
            case .timeout:
                print("❌ 请求超时，请稍后重试")
            case .rateLimited:
                print("❌ 超出速率限制，请等待一段时间后重试")
            case .taskFailed(let message):
                print("❌ 任务失败: \(message)")
            case .requestFailed(let code, _):
                print("❌ HTTP 错误: \(code)")
            default:
                print("❌ 其他错误: \(error.localizedDescription)")
            }
        }
    }
}
