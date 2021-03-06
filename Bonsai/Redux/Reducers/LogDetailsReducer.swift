//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct LogDetailsReducer {
    static func reduce(state: AppState, action: LogDetailsAction) -> AppState {
        switch action {
        case let .initState(loggable):
            return initState(state: state, loggable: loggable)
        case let .fetchLogDataSuccess(loggable):
            return fetchLogDataSuccess(state: state, loggable: loggable)
        case let .fetchLogDataError(error):
            return fetchLogDataError(state: state, error: error)
        case .initSymptomLogAnalytics:
            return initSymptomLogAnalytics(state: state)
        case .initSymptomLogAnalyticsSuccess(let result):
            return initSymptomLogAnalyticsSuccess(state: state, analyticsResult: result)
        case .initSymptomLogAnalyticsFailure(let error):
            return initSymptomLogAnalyticsFailure(state: state, error: error)
        case .deleteCurrentLog:
            return deleteLog(state: state)
        case let .deleteSuccess(deletedLog):
            return deleteSuccess(state: state, deletedLog: deletedLog)
        case let .deleteError(error):
            return deleteError(state: state, error: error)
        case .errorPopupShown:
            return errorPopupShown(state: state)
        case .screenDidDismiss:
            return screenDidDismiss(state: state)
        }
    }

    static private func initState(state: AppState, loggable: Loggable) -> AppState {
        var newState = state
        // Start in loading with a fresh state
        var logDetailState = LogDetailState()
        logDetailState.loggable = loggable
        logDetailState.isLoading = true
        newState.logDetails = logDetailState
        return newState
    }

    static private func fetchLogDataSuccess(state: AppState, loggable: Loggable) -> AppState {
        var newState = state
        newState.logDetails.isLoading = false
        newState.logDetails.loggable = loggable
        return newState
    }

    static private func fetchLogDataError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.logDetails.isLoading = false
        newState.logDetails.loadError = error
        return newState
    }

    static private func initSymptomLogAnalytics(state: AppState) -> AppState {
        var newState = state
        newState.logDetails.isLoadingAnalytics = true
        newState.logDetails.symptomSeverityAnalytics = nil
        return newState
    }

    static private func initSymptomLogAnalyticsSuccess(state: AppState, analyticsResult: SymptomSeverityAnalytics) -> AppState {
        var newState = state
        newState.logDetails.isLoadingAnalytics = false
        newState.logDetails.symptomSeverityAnalytics = analyticsResult
        return newState
    }

    static private func initSymptomLogAnalyticsFailure(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.logDetails.isLoadingAnalytics = false
        newState.logDetails.loadAnalyticsError = error
        newState.logDetails.symptomSeverityAnalytics = nil
        return newState
    }

    static private func fetchLogData(state: AppState) -> AppState {
        var newState = state
        newState.logDetails.isLoading = true
        return newState
    }
    
    static private func deleteLog(state: AppState) -> AppState {
        var newState = state
        newState.logDetails.isDeleting = true
        return newState
    }

    static private func deleteSuccess(state: AppState, deletedLog: Loggable) -> AppState {
        var newState = state
        newState.logDetails.isDeleting = false
        newState.logDetails.deleteSuccess = true
        return newState
    }
    
    static private func deleteError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.logDetails.deleteError = error
        newState.logDetails.isDeleting = false
        return newState
    }

    static private func errorPopupShown(state: AppState) -> AppState {
        // Reset all errors
        var newState = state
        newState.logDetails.loadError = nil
        newState.logDetails.deleteError = nil
        return newState
    }
    
    static private func screenDidDismiss(state: AppState) -> AppState {
        var newState = state
        // Completely reset the state
        newState.logDetails = LogDetailState()
        return newState
    }
    
}
