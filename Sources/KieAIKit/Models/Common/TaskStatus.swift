//
//  TaskStatus.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// The status of an asynchronous generation task.
public enum TaskStatus: String, Codable, Sendable {

    /// The task is waiting to be processed.
    case waiting = "waiting"

    /// The task is pending (queued).
    case pending = "pending"

    /// The task is currently being processed.
    case processing = "processing"

    /// The task completed successfully.
    case success = "success"

    /// The task failed.
    case failed = "failed"

    /// The task was cancelled.
    case cancelled = "cancelled"

    /// Whether the task is in a terminal state (completed or failed).
    public var isTerminal: Bool {
        switch self {
        case .success, .failed, .cancelled:
            return true
        case .waiting, .pending, .processing:
            return false
        }
    }

    /// Whether the task completed successfully.
    public var isSuccess: Bool {
        return self == .success
    }

    /// Whether the task failed.
    public var isFailed: Bool {
        return self == .failed
    }

    /// Whether the task is still in progress.
    public var isInProgress: Bool {
        return !isTerminal
    }
}
