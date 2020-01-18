//
// Created by Frank Jia on 2020-01-16.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// Util for modifying state for loggable CRUD operations
// This allows for a centralized place where we can change state of logs
struct GlobalLogReducerUtil {

    static func add(state: inout AppState, newLog: Loggable) {
        state.homeScreen.recentLogs.insert(newLog, at: 0)
    }

    static func delete(state: inout AppState, deletedLogId: String) {
        state.homeScreen.recentLogs.removeAll { loggable in loggable.id == deletedLogId }
    }

}