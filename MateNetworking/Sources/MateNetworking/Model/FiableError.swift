//
//  FiableError.swift
//  Networking
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Foundation
import CodeGen

/// FiableError Custom Api endpoint Request Error
///
///
public enum FiableError: Error, Decodable, Equatable, GeneratedFakeable {

    /// Non explicit reason
    ///
    case empty

    /// Missing Token!
    ///
    case unauthorized

    /// We're not properly authenticated
    ///
    case invalidToken

    /// Remote Request Failed
    ///
    case requestFailed

    /// No route was found matching the URL and request method
    ///
    case noRestRoute

    /// Unknown: Represents an unmapped remote error. Capisce?
    ///
    case unknown(code: String, message: String?)

    /// Stats error cases - API documentation of possible errors:
    /// https://developer.wordpress.com/docs/api/1.1/get/sites/%24site/stats/
    /// Note: when the cases get large, consider refactoring them into a separate error enum that conforms to a Dotcom error protocol

    /// No permission to view site stats
    case noStatsPermission

    /// The requested resourced does not exist remotely
    case resourceDoesNotExist

    /// Decodable Initializer.
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let error = try container.decodeIfPresent(String.self, forKey: .error) ?? ""
        let message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""

        switch error {
        case Constants.invalidToken:
            self = .invalidToken
        case Constants.requestFailed:
            self = .requestFailed
        case Constants.unauthorized where message == ErrorMessages.noStatsPermission:
            self = .noStatsPermission
        case Constants.unauthorized:
            self = .unauthorized
        case Constants.noRestRoute:
            self = .noRestRoute
        case Constants.restTermInvalid where message == ErrorMessages.resourceDoesNotExist:
            self = .resourceDoesNotExist
        default:
            self = .unknown(code: error, message: message)
        }
    }


    /// Constants for Possible Error Identifiers
    ///
    private enum Constants {
        static let unauthorized     = "Unauthenticated"
        static let invalidToken     = "invalid_token"
        static let requestFailed    = "http_request_failed"
        static let noRestRoute      = "rest_no_route"
        static let restTermInvalid  = "woocommerce_rest_term_invalid"
        static let unknownToken     = "unknown_token"
    }

    /// Coding Keys
    ///
    private enum CodingKeys: String, CodingKey {
        case error
        case message
    }

    /// Possible Error Messages
    ///
    private enum ErrorMessages {
        static let statsModuleDisabled = "This blog does not have the Stats module enabled"
        static let noStatsPermission = "user cannot view stats"
        static let resourceDoesNotExist = "Resource does not exist."
        static let jetpackNotConnected = "This blog does not have Jetpack connected"
    }
}


// MARK: - CustomStringConvertible Conformance
//
extension FiableError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .empty:
            return NSLocalizedString("Dotcom Response Empty", comment: "WordPress.com Error thrown when the response body is empty")
        case .invalidToken:
            return NSLocalizedString("Dotcom Token Invalid", comment: "WordPress.com Invalid Token")
        case .requestFailed:
            return NSLocalizedString("Dotcom Request Failed", comment: "WordPress.com Request Failure")
        case .unauthorized:
            return NSLocalizedString("Dotcom Missing Token", comment: "WordPress.com Missing Token")
        case .noRestRoute:
            return NSLocalizedString("Dotcom Invalid REST Route", comment: "WordPress.com error thrown when the the request REST API url is invalid.")
        case .noStatsPermission:
            return NSLocalizedString("Dotcom No Stats Permission", comment: "WordPress.com error thrown when the user has no permission to view site stats.")
        case .resourceDoesNotExist:
            return NSLocalizedString("Dotcom Resource does not exist", comment: "WordPress.com error thrown when a requested resource does not exist remotely.")
        case .unknown(let code, let message):
            let theMessage = message ?? String()
            let messageFormat = NSLocalizedString(
                "Fiable Error: [%1$@] %2$@",
                comment: "Custom Fiable Endpoint (unmapped!) error. Parameters: %1$@ - code, %2$@ - message"
            )
            return String.localizedStringWithFormat(messageFormat, code, theMessage)
        }
    }
}


// MARK: - Equatable Conformance
//
public func ==(lhs: FiableError, rhs: FiableError) -> Bool {
    switch (lhs, rhs) {
    case (.requestFailed, .requestFailed),
        (.unauthorized, .unauthorized),
        (.noRestRoute, .noRestRoute),
        (.noStatsPermission, .noStatsPermission):
        return true
    case let (.unknown(codeLHS, _), .unknown(codeRHS, _)):
        return codeLHS == codeRHS
    default:
        return false
    }
}
