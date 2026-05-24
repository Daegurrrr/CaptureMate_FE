//
//  MultipartFormData.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation

struct MultipartFormData {
    let boundary = UUID().uuidString
    private(set) var body = Data()

    mutating func appendText(name: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    mutating func appendFile(
        name: String,
        filename: String,
        mimeType: String,
        data: Data
    ) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    mutating func finalize() {
        body.append("--\(boundary)--\r\n")
    }

    var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
}

private extension Data {
    mutating func append(_ string: String) {
        append(Data(string.utf8))
    }
}
