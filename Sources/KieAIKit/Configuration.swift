//
//  Configuration.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Configuration for the KieAIKit client.
///
/// Use this struct to configure your API key and optional custom base URL.
public struct Configuration {

    /// The API key for authenticating with Kie.ai.
    ///
    /// **Important:** Keep your API key secure. Never commit it to version control.
    /// Consider using environment variables or secure storage for production apps.
    public let apiKey: String

    /// The base URL for the Kie.ai API.
    ///
    /// Defaults to `https://api.kie.ai/api/v1`. You typically don't need to change this
    /// unless you're working with a custom API endpoint or testing environment.
    public let baseURL: String

    /// Default timeout for network requests in seconds.
    public let timeout: TimeInterval

    /// Creates a new configuration.
    ///
    /// - Parameters:
    ///   - apiKey: Your Kie.ai API key
    ///   - baseURL: The base URL for the API (optional, defaults to official API)
    ///   - timeout: Request timeout in seconds (optional, defaults to 60)
    public init(
        apiKey: String,
        baseURL: String = "https://api.kie.ai/api/v1",
        timeout: TimeInterval = 60.0
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.timeout = timeout
    }

    /// Creates a configuration using environment variables.
    ///
    /// This convenience initializer looks for the `KIE_AI_API_KEY` environment variable.
    /// Useful for development and testing.
    ///
    /// - Returns: A configuration if the environment variable is set, nil otherwise.
    public static func fromEnvironment() -> Configuration? {
        guard let apiKey = ProcessInfo.processInfo.environment["KIE_AI_API_KEY"] else {
            return nil
        }
        return Configuration(apiKey: apiKey)
    }
}
