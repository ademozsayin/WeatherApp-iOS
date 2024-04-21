//
//  MateEvent.swift
//
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI

// MARK: - MateEvent
public struct MateEvent: Codable, Equatable {
    
    public static func == (lhs: MateEvent, rhs: MateEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: Int
    public let name: String?
    public let startTime: String?
    public let categoryID: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let userID: String?
    public let address: String?
    public let latitude: String?
    public let longitude: String?
    public let maxAttendees: String?
    public let joinedAttendees: String?
    public let category: MateCategory?
    public let user: MateUser?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case startTime = "start_time"
        case categoryID = "category_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case address = "address"
        case latitude = "latitude"
        case longitude = "longitude"
        case maxAttendees = "max_attendees"
        case joinedAttendees = "joined_attendees"
        case category = "category"
        case user = "user"
    }
}

public extension MateEvent {
    var markerIcon: String {
        if let categoryID {
            switch categoryID {
            case "1":
                return "soccerball"
            case "2":
                return "basketball"
            case "3":
                return "figure.table.tennis"
            default:
                return "􀜇"
            }
        }
        return "􀜇"
    }
    
    var tintColor: Color {
        var uiColor = UIColor.blue
        if let categoryID {
            switch categoryID {
            case "1":
                uiColor =  UIColor.green
            case "2":
                uiColor =  UIColor.orange
            case "3":
                uiColor =  UIColor.red
            default:
                uiColor =  UIColor.blue
            }
        }
        let color = Color(uiColor)
        return color
    }
}

