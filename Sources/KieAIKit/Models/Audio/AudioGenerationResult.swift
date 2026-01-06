//
//  AudioGenerationResult.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Result of a successful audio generation.
public struct AudioGenerationResult: Codable, Sendable {

    /// The task ID for this generation.
    public let taskId: String

    /// URL to the generated audio file.
    public let audioURL: URL

    /// URL to a waveform visualization image (optional).
    public let waveformURL: URL?

    /// The model used for generation.
    public let model: String

    /// The prompt used for generation.
    public let prompt: String

    /// Duration of the audio in seconds.
    public let duration: Double?

    /// Audio format (mp3, wav, etc.).
    public let format: String?

    /// Sample rate in Hz.
    public let sampleRate: Int?

    /// Number of channels (1=mono, 2=stereo).
    public let channels: Int?

    /// File size in bytes.
    public let fileSize: Int?

    /// Seed used for generation.
    public let seed: Int?

    /// Additional metadata.
    public let metadata: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case audioURL = "audio_url"
        case waveformURL = "waveform_url"
        case model
        case prompt
        case duration
        case format
        case sampleRate = "sample_rate"
        case channels
        case fileSize = "file_size"
        case seed
        case metadata
    }

    public init(
        taskId: String,
        audioURL: URL,
        waveformURL: URL? = nil,
        model: String,
        prompt: String,
        duration: Double? = nil,
        format: String? = nil,
        sampleRate: Int? = nil,
        channels: Int? = nil,
        fileSize: Int? = nil,
        seed: Int? = nil,
        metadata: [String: String]? = nil
    ) {
        self.taskId = taskId
        self.audioURL = audioURL
        self.waveformURL = waveformURL
        self.model = model
        self.prompt = prompt
        self.duration = duration
        self.format = format
        self.sampleRate = sampleRate
        self.channels = channels
        self.fileSize = fileSize
        self.seed = seed
        self.metadata = metadata
    }
}
