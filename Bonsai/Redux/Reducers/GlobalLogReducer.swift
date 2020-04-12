//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalLogReducer {
    static func reduce(state: AppState, action: GlobalLogAction) -> AppState {
        switch action {
        // Log Actions
        case .insert(let logs):
            return insert(state: state, logs: logs)
        case .replace(let logs, let date):
            return replace(state: state, logs: logs, date: date)
        case .delete(let log):
            return delete(state: state, log: log)
        case .markAsRetrieved(let dates):
            return markAsRetrieved(state: state, dates: dates)
        // Analytics
        case .updateAnalytics:
            return updateAnalytics(state: state)
        case .analyticsLoadSuccess(let analytics):
            return analyticsLoadSuccess(state: state, analytics: analytics)
        case .analyticsLoadError(let error):
            return analyticsLoadError(state: state, error: error)
        }
    }

    static private func insert(state: AppState, logs: [Loggable]) -> AppState {
        var newState = state
        for log in logs {
            // This is not very performant, but leaving for now
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

    static private func markAsRetrieved(state: AppState, dates: [Date]) -> AppState {
        var newState = state
        newState.globalLogs.markAsRetrieved(for: dates)
        return newState
    }
    
    static private func updateAnalytics(state: AppState) -> AppState {
        var newState = state
        newState.globalLogs.isLoadingAnalytics = true
        newState.globalLogs.loadAnalyticsError = nil
        return newState
    }
    
    static private func analyticsLoadSuccess(state: AppState, analytics: LogAnalytics) -> AppState {
        var newState = state
        newState.globalLogs.isLoadingAnalytics = false
        newState.globalLogs.analytics = analytics
        newState.globalLogs.loadAnalyticsError = nil
        return newState
    }

    static private func analyticsLoadError(state: AppState, error: Error) -> AppState {
        var newState = state
        newState.globalLogs.isLoadingAnalytics = false
        newState.globalLogs.analytics = nil
        newState.globalLogs.loadAnalyticsError = error
        return newState
    }

}
