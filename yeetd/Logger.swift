//
//  Logger.swift
//  yeetd
//
//  Created by Michael Thomas on 9/21/23.
//
//  https://www.avanderlee.com/debugging/oslog-unified-logging/

import Foundation
import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = "dev.biscuit.yeetd"

    /// Logs the view cycles like a view that appeared.
    static let processManagement = Logger(subsystem: subsystem, category: "process-management")
}
