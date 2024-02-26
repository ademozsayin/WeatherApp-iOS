//
//  AppDelegate+Init.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import CocoaLumberjack
#if DEBUG
import Wormholy
#endif

// MARK: - Initialization Methods
extension AppDelegate {

    /// Sets up CocoaLumberjack logging.
    ///
    final func setupCocoaLumberjack() {
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7

        guard let logger = fileLogger as? DDFileLogger else {
            return
        }
        DDLog.add(DDOSLogger.sharedInstance)
        DDLog.add(logger)
        DDLogVerbose("👀 setupCocoaLumberjack...")

    }

    /// Sets up the current Log Level.
    ///
    final func setupLogLevel(_ level: DDLogLevel) {
        CocoaLumberjack.dynamicLogLevel = level
        DDLogVerbose("👀 setupLogLevel to \(level)")

    }
    
    /// Set up Wormholy only in Debug build configuration
    ///
    func setupWormholy() {
        #if DEBUG
        /// We want to activate it programmatically, not using the shake.
        Wormholy.shakeEnabled = false
        DDLogVerbose("👀 setupWormholy  ")
        #endif
    }

}