//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalLogReminderReducer {
    static func reduce(state: AppState, action: GlobalLogReminderAction) -> AppState {
        switch action {
        case let .addOrUpdate(logReminder):
            return addOrUpdate(state: state, logReminder: logReminder)
        case let .addOrUpdateMany(logReminders):
            return addOrUpdateMany(state: state, logReminders: logReminders)
        case let .remove(logReminder):
            return remove(state: state, logReminder: logReminder)
        }
    }

    static private func addOrUpdate(state: AppState, logReminder: LogReminder) -> AppState {
        var newState = state
        newState.globalLogReminders.logReminders.update(with: logReminder)
        return newState
    }

    static private func addOrUpdateMany(state: AppState, logReminders: [LogReminder]) -> AppState {
        var newState = state
        for logReminder in logReminders {
            newState.globalLogReminders.logReminders.insert(logReminder)
        }
        return newState
    }

    static private func remove(state: AppState, logReminder: LogReminder) -> AppState {
        var newState = state
        if newState.globalLogReminders.logReminders.remove(logReminder) == nil {
            AppLogging.warn("Log reminder was never contained in the state")
        }
        return newState
    }

}
