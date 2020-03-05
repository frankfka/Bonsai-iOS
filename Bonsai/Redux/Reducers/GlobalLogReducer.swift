//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalLogReducer {
    static func reduce(state: AppState, action: GlobalLogAction) -> AppState {
        switch action {
        case .insert(let log):
            return insert(state: state, log: log)
        case .insertMany(let logs):
            return insertMany(state: state, logs: logs)
        case .replace(let logs, let date):
            return replace(state: state, logs: logs, date: date)
        case .delete(let log):
            return delete(state: state, log: log)
        case .markAsRetrieved(let date):
            return markAsRetrieved(state: state, date: date)
        }
    }

    static private func insert(state: AppState, log: Loggable) -> AppState {
        var newState = state
        newState.globalLogs.insert(log)
        return newState
    }

    static private func insertMany(state: AppState, logs: [Loggable]) -> AppState {
        var newState = state
        for log in logs {
            newState.globalLogs.insert(log)
        }
        return newState
    }

    static private func replace(state: AppState, logs: [Loggable], date: Date) -> AppState {
        var newState = state
        newState.globalLogs.replace(logs: logs, for: date)
        return newState
    }

    static private func delete(state: AppState, log: Loggable) -> AppState {
        var newState = state
        newState.globalLogs.delete(log)
        return newState
    }

    static private func markAsRetrieved(state: AppState, date: Date) -> AppState {
        var newState = state
        newState.globalLogs.markAsRetrieved(for: date)
        return newState
    }

}