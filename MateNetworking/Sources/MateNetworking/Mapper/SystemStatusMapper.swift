//
//  File.swift
//  
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation

/// Mapper: System Status
///
struct SystemStatusMapper: Mapper {

    /// We're injecting this field via `JSONDecoder.userInfo` because the remote endpoints don't return the SiteID in the system plugin endpoint.
    ///
    /// (Attempts) to convert a dictionary into SystemStatus
    ///
    func map(response: Data) throws -> SystemStatus {
        let decoder = JSONDecoder()
        if hasDataEnvelope(in: response) {
            return try decoder.decode(SystemStatusEnvelope.self, from: response).systemStatus
        } else {
            return try decoder.decode(SystemStatus.self, from: response)
        }
    }
}

/// System Status endpoint returns the requested account in the `data` key. This entity
/// allows us to parse it with JSONDecoder.
///
struct SystemStatusEnvelope: Decodable {
    let systemStatus: SystemStatus

    private enum CodingKeys: String, CodingKey {
        case systemStatus = "data"
    }
}