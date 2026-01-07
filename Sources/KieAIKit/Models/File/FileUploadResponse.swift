//
//  FileUploadResponse.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Response from file upload API.
public struct FileUploadResponse: Codable, Sendable {

    /// Whether the upload was successful.
    public let success: Bool

    /// Response code (200 for success).
    public let code: Int

    /// Response message.
    public let message: String

    /// Uploaded file information.
    public let data: UploadedFile

    private enum CodingKeys: String, CodingKey {
        case success
        case code
        case message = "msg"
        case data
    }
}

/// Information about an uploaded file.
public struct UploadedFile: Codable, Sendable {

    /// The file name as stored on the server.
    public let fileName: String

    /// The file path on the server.
    public let filePath: String

    /// The URL to download the file directly.
    public let downloadUrl: URL

    /// File size in bytes.
    public let fileSize: Int

    /// MIME type of the file.
    public let mimeType: String

    /// When the file was uploaded.
    public let uploadedAt: Date?

    /// Convenience property to get download URL.
    public var fileURL: URL {
        return downloadUrl
    }

    private enum CodingKeys: String, CodingKey {
        case fileName
        case filePath
        case downloadUrl
        case fileSize
        case mimeType
        case uploadedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        fileName = try container.decode(String.self, forKey: .fileName)
        filePath = try container.decode(String.self, forKey: .filePath)
        downloadUrl = try container.decode(URL.self, forKey: .downloadUrl)
        fileSize = try container.decode(Int.self, forKey: .fileSize)
        mimeType = try container.decode(String.self, forKey: .mimeType)

        // Handle date field
        if let dateString = try? container.decode(String.self, forKey: .uploadedAt) {
            let dateFormatter = ISO8601DateFormatter()
            uploadedAt = dateFormatter.date(from: dateString)
        } else {
            uploadedAt = nil
        }
    }

    public init(
        fileName: String,
        filePath: String,
        downloadUrl: URL,
        fileSize: Int,
        mimeType: String,
        uploadedAt: Date? = nil
    ) {
        self.fileName = fileName
        self.filePath = filePath
        self.downloadUrl = downloadUrl
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.uploadedAt = uploadedAt
    }
}
