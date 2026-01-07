//
//  FileUploadService.swift
//  KieAIKit
//
//  Created for the Kie.ai community SDK.
//

import Foundation

/// Service for uploading files to KIE's file storage.
///
/// Files uploaded via this service are stored temporarily and accessible for 3 days.
/// This is useful for uploading images/video for use with generation models.
public final class FileUploadService {

    /// The file upload API base URL (different from main API).
    private let fileUploadBaseURL = "https://kieai.redpandaai.co"

    /// The API client for making requests.
    private let apiClient: APIClient

    /// Creates a new file upload service.
    /// - Parameter apiClient: The API client to use
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - URL Upload

    /// Uploads a file from a remote URL.
    ///
    /// The server will download the file from the URL and store it.
    ///
    /// - Parameters:
    ///   - url: The remote URL to download from
    ///   - uploadPath: Optional directory path (e.g., "images", "videos")
    ///   - fileName: Optional custom filename (auto-generated if nil)
    /// - Returns: Uploaded file information with access URLs
    /// - Throws: An APIError if upload fails
    public func uploadFromURL(
        _ url: URL,
        uploadPath: String? = nil,
        fileName: String? = nil
    ) async throws -> UploadedFile {
        struct URLUploadBody: Encodable {
            let fileUrl: String
            let uploadPath: String?
            let fileName: String?
        }

        let body = URLUploadBody(
            fileUrl: url.absoluteString,
            uploadPath: uploadPath,
            fileName: fileName
        )

        return try await performUpload(
            endpoint: "file-url-upload",
            body: body,
            useJson: true
        )
    }

    // MARK: - Base64 Upload

    /// Uploads a file from Base64 encoded data.
    ///
    /// Useful when you have the file data in memory (e.g., from UIImage).
    ///
    /// - Parameters:
    ///   - base64Data: Base64 encoded file data (with or without data URI prefix)
    ///   - uploadPath: Optional directory path (e.g., "images", "videos")
    ///   - fileName: Optional custom filename (auto-generated if nil)
    /// - Returns: Uploaded file information with access URLs
    /// - Throws: An APIError if upload fails
    public func uploadBase64(
        _ base64Data: String,
        uploadPath: String? = nil,
        fileName: String? = nil
    ) async throws -> UploadedFile {
        print("📤 uploadBase64 called, data length: \(base64Data.count), uploadPath: \(uploadPath ?? "nil")")

        struct Base64UploadBody: Encodable {
            let base64Data: String
            let uploadPath: String?
            let fileName: String?
        }

        let body = Base64UploadBody(
            base64Data: base64Data,
            uploadPath: uploadPath,
            fileName: fileName
        )

        print("📤 Calling performUpload with endpoint: file-base64-upload")

        return try await performUpload(
            endpoint: "file-base64-upload",
            body: body,
            useJson: true
        )
    }

    /// Uploads raw file data as Base64.
    ///
    /// Convenience method that converts Data to Base64 and uploads.
    ///
    /// - Parameters:
    ///   - data: Raw file data
    ///   - uploadPath: Optional directory path
    ///   - fileName: Optional custom filename
    /// - Returns: Uploaded file information with access URLs
    /// - Throws: An APIError if upload fails
    public func uploadData(
        _ data: Data,
        uploadPath: String? = nil,
        fileName: String? = nil
    ) async throws -> UploadedFile {
        let base64String = data.base64EncodedString()
        return try await uploadBase64(base64String, uploadPath: uploadPath, fileName: fileName)
    }

    // MARK: - Stream Upload (FormData)

    /// Uploads a file using multipart/form-data.
    ///
    /// This is the traditional file upload method. For iOS, you can
    /// convert your file to Data and use `uploadData()` instead.
    ///
    /// - Parameters:
    ///   - fileData: The file data to upload
    ///   - name: The form field name for the file
    ///   - filename: The filename to use
    ///   - mimeType: The MIME type of the file
    ///   - uploadPath: Optional directory path
    /// - Returns: Uploaded file information with access URLs
    /// - Throws: An APIError if upload fails
    public func uploadFile(
        _ fileData: Data,
        name: String = "file",
        filename: String,
        mimeType: String,
        uploadPath: String? = nil
    ) async throws -> UploadedFile {
        // Create multipart form data boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // Add uploadPath if provided
        if let uploadPath = uploadPath {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"uploadPath\"\r\n\r\n".data(using: .utf8)!)
            body.append(uploadPath.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Create request
        guard let url = URL(string: "\(fileUploadBaseURL)/api/file-stream-upload") else {
            throw APIError.invalidURL(fileUploadBaseURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiClient.configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(NSError(domain: "KieAIKit", code: -1))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(httpResponse.statusCode, data)
        }

        // Decode response
        let decoder = JSONDecoder()
        let uploadResponse = try decoder.decode(FileUploadResponse.self, from: data)

        guard uploadResponse.success else {
            throw APIError.serverError(uploadResponse.message)
        }

        return uploadResponse.data
    }

    // MARK: - Private Helper

    /// Performs an upload request with JSON body.
    private func performUpload<Body: Encodable>(
        endpoint: String,
        body: Body,
        useJson: Bool
    ) async throws -> UploadedFile {
        let fullURL = "\(fileUploadBaseURL)/api/\(endpoint)"
        print("📡 performUpload: \(fullURL)")

        guard let url = URL(string: fullURL) else {
            throw APIError.invalidURL(endpoint)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiClient.configuration.apiKey)", forHTTPHeaderField: "Authorization")

        if useJson {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            let requestBody = try encoder.encode(body)
            request.httpBody = requestBody

            // Debug: print request body (truncated if too long)
            if let bodyString = String(data: requestBody, encoding: .utf8) {
                let preview = bodyString.count > 500 ? String(bodyString.prefix(500)) + "..." : bodyString
                print("📤 Request body: \(preview)")
            }
        }

        print("⏳ Sending request...")

        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        print("📥 Response received, \(data.count) bytes")

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(NSError(domain: "KieAIKit", code: -1))
        }

        print("📊 Status code: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ HTTP error: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error response: \(errorString)")
            }
            throw APIError.requestFailed(httpResponse.statusCode, data)
        }

        // DEBUG: Print response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 File upload API response: \(jsonString)")
        }

        // Decode response
        let decoder = JSONDecoder()
        let uploadResponse = try decoder.decode(FileUploadResponse.self, from: data)

        guard uploadResponse.success else {
            throw APIError.serverError(uploadResponse.message)
        }

        return uploadResponse.data
    }
}
