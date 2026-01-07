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

    /// Unique file identifier.
    public let fileId: String

    /// The file name as stored on the server.
    public let fileName: String

    /// The original file name before upload.
    public let originalName: String

    /// File size in bytes.
    public let fileSize: Int

    /// MIME type of the file.
    public let mimeType: String

    /// The upload path/directory.
    public let uploadPath: String

    /// The URL to access the uploaded file.
    public let fileURL: URL

    /// The URL to download the file directly.
    public let downloadURL: URL

    /// When the file was uploaded.
    public let uploadTime: Date?

    /// When the file will expire (typically 3 days after upload).
    public let expiresAt: Date?

    private enum CodingKeys: String, CodingKey {
        case fileId
        case fileName
        case originalName = "originalName"
        case fileSize
        case mimeType
        case uploadPath
        case fileURL = "fileUrl"
        case downloadURL = "downloadUrl"
        case uploadTime
        case expiresAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        fileId = try container.decode(String.self, forKey: .fileId)
        fileName = try container.decode(String.self, forKey: .fileName)
        originalName = try container.decode(String.self, forKey: .originalName)
        fileSize = try container.decode(Int.self, forKey: .fileSize)
        mimeType = try container.decode(String.self, forKey: .mimeType)
        uploadPath = try container.decode(String.self, forKey: .uploadPath)
        fileURL = try container.decode(URL.self, forKey: .fileURL)
        downloadURL = try container.decode(URL.self, forKey: .downloadURL)

        // Handle optional date fields
        let dateFormatter = ISO8601DateFormatter()
        uploadTime = try? container.decodeIfPresent(Date.self, forKey: .uploadTime)
        expiresAt = try? container.decodeIfPresent(Date.self, forKey: .expiresAt)
    }
}
