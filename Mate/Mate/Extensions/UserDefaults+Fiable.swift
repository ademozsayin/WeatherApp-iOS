//
//  UserDefaults+Fiable.swift
//  Mate
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Foundation



// MARK: - Main App UserDefaults Keys
//
extension UserDefaults {
    enum Key: String {
        case defaultCredentialsType
        case defaultAccountID
        case defaultUsername
        case defaultSiteAddress
        case defaultStoreID
        case defaultStoreName
        case defaultStoreCurrencySettings
        case defaultAnonymousID
        case defaultRoles
        case deviceID
        case deviceToken
        case errorLoginSiteAddress
        case hasFinishedOnboarding
        case installationDate
        case userOptedInAnalytics
        case userOptedInCrashLogging = "userOptedInCrashlytics"
        case versionOfLastRun
        case analyticsUsername
        case notificationsLastSeenTime
        case notificationsMarkAsReadCount
        case completedAllStoreOnboardingTasks
        case shouldHideStoreOnboardingTaskList
        case storePhoneNumber
        case siteIDsWithSnapshotTracked
        case hasSavedPrivacyBannerSettings
        case usedProductDescriptionAI

        // Tooltip
        case hasDismissedWriteWithAITooltip
        case numberOfTimesWriteWithAITooltipIsShown

        // Store profiler answers
        case storeProfilerAnswers

        // AI prompt tone
        case aiPromptTone

        // Whether the Blaze section on My Store screen has been dismissed
        case hasDismissedBlazeSectionOnMyStore

        // Product Creation AI
        case numberOfTimesProductCreationAISurveySuggested
        case didStartProductCreationAISurvey

        // Theme installation
        case themesPendingInstall

        // Store Creation
        case siteIDPendingStoreSwitch
        case expectedStoreNamePendingStoreSwitch
    }
}

extension UserDefaults {
    /// User defaults instance ready to be shared between extensions of the same group.
    ///
    static let group = UserDefaults(suiteName: FiableConstants.sharedUserDefaultsSuiteName)
}


// MARK: - Convenience Methods
//
extension UserDefaults {

    /// Returns the Object (if any) associated with the specified Key.
    ///
    func object<T>(forKey key: Key) -> T? {
        return value(forKey: key.rawValue) as? T
    }

    /// Stores the Key/Value Pair.
    ///
    func set<T>(_ value: T?, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    /// Nukes any object associated with the specified Key.
    ///
    func removeObject(forKey key: Key) {
        removeObject(forKey: key.rawValue)
    }

    /// Indicates if there's an entry for the specified Key.
    ///
    func containsObject(forKey key: Key) -> Bool {
        return value(forKey: key.rawValue) != nil
    }

    /// Subscript Accessible via our new Key type!
    ///
    subscript<T>(key: Key) -> T? {
        get {
            return value(forKey: key.rawValue) as? T
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    /// Subscript: "Type Inference Fallback". To be used whenever the type cannot be automatically inferred!
    ///
    subscript(key: Key) -> Any? {
        get {
            return value(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }
}