//
//  KieVideoModel.swift
//  KieAIKit
//
//  Generated from KIE Market video model docs.
//

import Foundation

/// Strongly-typed KIE video model identifiers.
///
/// Use this enum with `VideoService.createTask(model:input:...)`
/// to access the full set of documented video task types.
public enum KieVideoModel: String, Codable, Sendable {

    // MARK: - Kling
    case kling26TextToVideo = "kling-2.6/text-to-video"
    case kling26ImageToVideo = "kling-2.6/image-to-video"
    case kling25TurboProImageToVideo = "kling/v2-5-turbo-image-to-video-pro"
    case kling25TurboProTextToVideo = "kling/v2-5-turbo-text-to-video-pro"
    case klingAiAvatarStandard = "kling/ai-avatar-standard"
    case klingAiAvatarPro = "kling/ai-avatar-pro"
    case kling21MasterImageToVideo = "kling/v2-1-master-image-to-video"
    case kling21MasterTextToVideo = "kling/v2-1-master-text-to-video"
    case kling21Pro = "kling/v2-1-pro"
    case kling21Standard = "kling/v2-1-standard"
    case kling26MotionControl = "kling-2.6/motion-control"
    case kling30Video = "kling-3.0/video"

    // MARK: - Bytedance
    case bytedanceSeedance15Pro = "bytedance/seedance-1.5-pro"
    case bytedanceV1ProFastImageToVideo = "bytedance/v1-pro-fast-image-to-video"
    case bytedanceV1ProImageToVideo = "bytedance/v1-pro-image-to-video"
    case bytedanceV1ProTextToVideo = "bytedance/v1-pro-text-to-video"
    case bytedanceV1LiteImageToVideo = "bytedance/v1-lite-image-to-video"
    case bytedanceV1LiteTextToVideo = "bytedance/v1-lite-text-to-video"

    // MARK: - Hailuo
    case hailuo23ProImageToVideo = "hailuo/2-3-image-to-video-pro"
    case hailuo23StandardImageToVideo = "hailuo/2-3-image-to-video-standard"
    case hailuo02ProTextToVideo = "hailuo/02-text-to-video-pro"
    case hailuo02StandardTextToVideo = "hailuo/02-text-to-video-standard"
    case hailuo02ProImageToVideo = "hailuo/02-image-to-video-pro"
    case hailuo02StandardImageToVideo = "hailuo/02-image-to-video-standard"

    // MARK: - Sora2
    case sora2ImageToVideo = "sora-2-image-to-video"
    case sora2TextToVideo = "sora-2-text-to-video"
    case sora2ProImageToVideo = "sora-2-pro-image-to-video"
    case sora2ProTextToVideo = "sora-2-pro-text-to-video"
    case soraWatermarkRemover = "sora-watermark-remover"
    case sora2ProStoryboard = "sora-2-pro-storyboard"
    case sora2Characters = "sora-2-characters"
    case sora2CharactersPro = "sora-2-characters-pro"

    // MARK: - Wan
    case wan26ImageToVideo = "wan/2-6-image-to-video"
    case wan26TextToVideo = "wan/2-6-text-to-video"
    case wan26VideoToVideo = "wan/2-6-video-to-video"
    case wan22A14bTurboImageToVideo = "wan/2-2-a14b-image-to-video-turbo"
    case wan22A14bTurboTextToVideo = "wan/2-2-a14b-text-to-video-turbo"
    case wan22AnimateMove = "wan/2-2-animate-move"
    case wan22AnimateReplace = "wan/2-2-animate-replace"
    case wan22A14bTurboSpeechToVideo = "wan/2-2-a14b-speech-to-video-turbo"

    // MARK: - Grok Imagine
    case grokImagineTextToVideo = "grok-imagine/text-to-video"
    case grokImagineImageToVideo = "grok-imagine/image-to-video"
}

