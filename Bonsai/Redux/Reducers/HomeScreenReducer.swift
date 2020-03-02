//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct HomeScreenReducer {
    static func reduce(state: AppState, action: HomeScreenAction) -> AppState {
        switch action {
        case .screenDidShow:
            return state
        case .initializeData:
            return initializeData(state: state)
        case .dataLoadSuccess(let recentLogs):
            return dataLoadSuccess(state: state, recentLogs: recentLogs)
        case .dataLoadError(let error):
            return dataLoadError(state: state, error: error)
        case .analyticsLoadSuccess(let analytics):
            return analyticsLoadSuccess(state: state, analytics: analytics)
        case .analyticsLoadError(let error):
            return analyticsLoadError(state: state, error: error)
        }
    }

    static private func initializeData(state: AppState) -> AppState {
        var newState = state
        newState.homeScreen.isLoading = true
        newState.homeScreen.isLoadingAnalytics = true
        return newState
    }

    static private func dataLoadSuccess(state: AppState, recentLogs: [Loggable]) -> AppState {
        var newState = state
        newState.homeScreen.recentLogs = recentLogs
        newState.homeScreen.isLoading = false
        newState.homeScreen.initSuccess = true
        return newState
    }

    static private func dataLoadError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.homeScreen.recentLogs = []
        newState.homeScreen.isLoading = false
        newState.homeScreen.initFailure = error
        return newState
    }

    static private func analyticsLoadSuccess(state: AppState, analytics: LogAnalytics) -> AppState {
        var newState = state
        newState.homeScreen.isLoadingAnalytics = false
        newState.homeScreen.analytics = analytics
        return newState
    }

    static private func analyticsLoadError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.homeScreen.isLoadingAnalytics = false
        newState.homeScreen.analytics = nil
        newState.homeScreen.loadAnalyticsError = error
        return newState
    }
}
