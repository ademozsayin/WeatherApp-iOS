//
//  CrashLoggingStack.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Foundation
import OnsaFoundation

protocol CrashLoggingStack: CrashLogger {
    /// Forces the application to crash
    func crash()

    /// Causes the Crash Logging System to refresh its knowledge about the current state of the system.
    func setNeedsDataRefresh()

    /// Writes an error to the Crash Logging system.
    /// - Parameters:
    ///   - error: The error
    func logError(_ error: Error)

    /// Number of log files queued for upload
    var queuedLogFileCount: Int { get }
}