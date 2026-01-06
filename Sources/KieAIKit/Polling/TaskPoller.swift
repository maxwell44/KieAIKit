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

        while Date().timeIntervalSince(startTime) < timeout {
            do {
                let request = APIRequest<EmptyRequestBody>(
                    path: "\(endpoint)/\(taskId)",
                    method: .get
                )

                let urlRequest = try request.makeURLRequest(
                    baseURL: apiClient.configuration.baseURL,
                    apiKey: apiClient.configuration.apiKey
                )

                let (data, response) = try await apiClient.session.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown(URLError(.badServerResponse))
                }

                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.from(response: httpResponse, data: data)
                }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let taskInfo = try decoder.decode(TaskInfo.self, from: data)

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
                // Re-throw API errors (including timeout)
                throw apiError
            } catch {
                // For other errors, log and continue polling
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }

        throw APIError.timeout
    }
}
