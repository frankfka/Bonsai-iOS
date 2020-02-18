//
// Created by Frank Jia on 2020-01-16.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// Util for modifying state for loggable CRUD operations
// This allows for a centralized place where we can change state of logs
struct GlobalLogReducerUtil {

    static func add(state: inout AppState, newLog: Loggable) {
        // Home
        state.homeScreen.recentLogs.insert(newLog, at: 0) // View is responsible for limiting the number of results
        state.homeScreen.recentLogs.sort { first, second in first.dateCreated > second.dateCreated } // Descending (latest first)
        // View Logs
        let logsForDate = state.viewLogs.logsForDate(newLog.dateCreated)
        if !logsForDate.isEmpty {
            // Add the log only if the dictionary has already initialized logs for the new log date
            state.viewLogs.addLog(log: newLog, for: newLog.dateCreated)
        }
    }

    static func delete(state: inout AppState, deletedLog: Loggable) {
        // Home
        state.homeScreen.recentLogs.removeAll { loggable in loggable.id == deletedLog.id }
        // View Logs
        var logsForDate = state.viewLogs.logsForDate(deletedLog.dateCreated)
        // No need to check for existence - will just be empty if not initialized
        logsForDate.removeAll { loggable in loggable.id == deletedLog.id }
        state.viewLogs.replaceLogs(logsForDate, for: deletedLog.dateCreated)
    }

}