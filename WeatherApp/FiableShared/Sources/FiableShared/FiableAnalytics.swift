//
//  FiableAnalytics.swift
//
//
//  Created by Adem Özsayın on 19.03.2024.
//

import Foundation

// Constants
let WPAnalyticsStatEditorPublishedPostPropertyCategory = "with_categories"
let WPAnalyticsStatEditorPublishedPostPropertyPhoto = "with_photos"
let WPAnalyticsStatEditorPublishedPostPropertyTag = "with_tags"
let WPAnalyticsStatEditorPublishedPostPropertyVideo = "with_videos"

// Protocol for Analytics Tracker
protocol FiableAnalyticsTracker {
    func beginTimer(for stat: FiableAnalyticsStat)
    func endTimer(for stat: FiableAnalyticsStat, with properties: [String: Any])
    func track(_ stat: FiableAnalyticsStat)
    func track(_ stat: FiableAnalyticsStat, with properties: [String: Any])
    func trackString(_ event: String)
    func trackString(_ event: String, with properties: [String: Any])
    func beginSession()
    func endSession()
    func refreshMetadata()
    func clearQueuedEvents()
}

// Enum for Analytics Stat
enum FiableAnalyticsStat {
    case AnalyticsStatSignupButtonTapped
    // Add more stats as needed
}

// Analytics Manager
class FiableAnalytics {
    // Static trackers array
    static var trackers: [FiableAnalyticsTracker] = []

    // Register Tracker
    static func registerTracker(_ tracker: FiableAnalyticsTracker) {
        trackers.append(tracker)
    }

    // Clear Trackers
    static func clearTrackers() {
        trackers.removeAll()
    }

    // Begin Timer for Stat
    static func beginTimer(for stat: FiableAnalyticsStat) {
        for tracker in trackers {
            tracker.beginTimer(for: stat)
        }
    }

    // End Timer for Stat
    static func endTimer(for stat: FiableAnalyticsStat, with properties: [String: Any]) {
        for tracker in trackers {
            tracker.endTimer(for: stat, with: properties)
        }
    }

    // Track Stat
    static func track(_ stat: FiableAnalyticsStat) {
        for tracker in trackers {
            tracker.track(stat)
        }
    }

    // Track Stat with Properties
    static func track(_ stat: FiableAnalyticsStat, with properties: [String: Any]) {
        for tracker in trackers {
            tracker.track(stat, with: properties)
        }
    }

    // Track String Event
    static func trackString(_ event: String) {
        for tracker in trackers {
            tracker.trackString(event)
        }
    }

    // Track String Event with Properties
    static func trackString(_ event: String, with properties: [String: Any]) {
        for tracker in trackers {
            tracker.trackString(event, with: properties)
        }
    }

    // Begin Session
    static func beginSession() {
        for tracker in trackers {
            tracker.beginSession()
        }
    }

    // End Session
    static func endSession() {
        for tracker in trackers {
            tracker.endSession()
        }
    }

    // Refresh Metadata
    static func refreshMetadata() {
        for tracker in trackers {
            tracker.refreshMetadata()
        }
    }

    // Clear Queued Events
    static func clearQueuedEvents() {
        for tracker in trackers {
            tracker.clearQueuedEvents()
        }
    }
}
