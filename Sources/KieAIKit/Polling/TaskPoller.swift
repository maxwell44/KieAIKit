//
//  TaskPoller.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// A mechanism for polling task status until completion.
final class TaskPoller {

    /// The API client for making requests.
    private let apiClient: APIClient

    /// Default interval between polling attempts.
    private let defaultInterval: TimeInterval = 2.0

    /// Maximum number of polling attempts (prevents infinite loops)
    private let maxAttempts: Int = 10

    /// Creates a new task poller.
    /// - Parameter apiClient: The API client to use for polling
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    /// Polls a task until it reaches a terminal state.
    ///
    /// - Parameters:
    ///   - taskId: The ID of the task to poll
    ///   - endpoint: The endpoint path for polling (e.g., "tasks/status")
    ///   - interval: Seconds between polling attempts (default: 2)
    ///   - timeout: Maximum time to wait before timing out (default: 300 seconds / 5 minutes)
    /// - Returns: The final task info
    /// - Throws: An error if polling fails or times out
    func poll(
        taskId: String,
        endpoint: String,
        interval: TimeInterval = 2.0,
        timeout: TimeInterval = 300.0
    ) async throws -> TaskInfo {
        let startTime = Date()
        var attempts = 0

        while Date().timeIntervalSince(startTime) < timeout && attempts < maxAttempts {
            attempts += 1

            do {
                let request = APIRequest<EmptyRequestBody>(
                    path: "\(endpoint)/\(taskId)",
                    method: .get
                )

                // Use the new performAndUnwrap method to handle the wrapped response
                let taskInfo = try await apiClient.performAndUnwrap(request, as: TaskInfo.self)

                // Validate the task info
                try taskInfo.validate()

                if taskInfo.status.isTerminal {
                    if taskInfo.status.isSuccess {
                        return taskInfo
                    } else if taskInfo.status.isFailed {
                        throw APIError.taskFailed(taskInfo.errorMessage ?? "Task failed without error message")
                    } else {
                        throw APIError.taskFailed("Task was cancelled")
                    }
                }

                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

            } catch let apiError as APIError {
                // For fatal errors, fail immediately
                switch apiError {
                case .notFound, .unauthorized, .badRequest, .timeout:
                    throw apiError
                case .requestFailed(let code, _):
                    // For 5xx errors, continue polling (with max attempts limit)
                    if code >= 500 {
                        if attempts >= maxAttempts {
                            throw APIError.serverError("Max retry attempts (\(maxAttempts)) reached")
                        }
                        try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                    } else {
                        throw apiError
                    }
                case .serverError, .rateLimited:
                    // For these, continue polling (with max attempts limit)
                    if attempts >= maxAttempts {
                        throw apiError
                    }
                    try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                default:
                    throw apiError
                }
            } catch {
                // For decoding and other errors, continue polling (with max attempts limit)
                if attempts >= maxAttempts {
                    throw APIError.decodingFailed(error)
                }
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }

        if attempts >= maxAttempts {
            throw APIError.timeout
        }

        throw APIError.timeout
    }
}
