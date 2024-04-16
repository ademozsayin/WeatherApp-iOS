//
//  Account.swift
//  Networking
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Foundation
import CodeGen

/// OnsaApi Account
///
public struct Account: Decodable, Equatable, GeneratedFakeable {

    /// OnsaApi UserID
    ///
    public let userID: Int64

    /// Display Name
    ///
    public let name: String

    /// Account's Email
    ///
    public let email: String


    public let gravatarUrl:String?
    /// Designated Initializer.
    ///
    public init(userID: Int64, name: String, email: String, gravatarUrl:String?) {
        self.userID = userID
        self.name = name
        self.email = email
        self.gravatarUrl = gravatarUrl
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let userID = container.failsafeDecodeIfPresent(targetType: Int.self,
                                                       forKey: .userID,
                                                       alternativeTypes: [.integer(transform: {  ($0) })]) ?? 0

        let name = try container.decode(String.self, forKey: .name)
        let email = try container.decode(String.self, forKey: .email)
        let gravatarUrl = try container.decodeIfPresent(String.self, forKey: .gravatarUrl) ?? ""
        
        self.init(userID: Int64(userID), name: name, email: email, gravatarUrl: gravatarUrl)
    }
}


/// Defines all of the Account CodingKeys
///
private extension Account {

    enum CodingKeys: String, CodingKey {
        case userID         = "id"
        case email          = "email"
        case name
        case gravatarUrl
    }
    

}
