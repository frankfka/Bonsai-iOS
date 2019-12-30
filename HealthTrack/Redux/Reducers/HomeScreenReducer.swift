//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct HomeScreenReducer {
    static func reduce(state: AppState, action: HomeScreenAction) -> AppState {
        switch action {
        case .screenDidShow:
            break
        case .initializeData:
            return initializeData(state: state)
        case .dataLoadSuccess(let recentLogs):
            return dataLoadSuccess(state: state, recentLogs: recentLogs)
        case .dataLoadError(let error):
            return dataLoadError(state: state, error: error)
        }
        return state
    }

    static private func initializeData(state: AppState) -> AppState {
        var newState = state
        newState.homeScreen.isLoading = true
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
        var newState = state
        newState.homeScreen.recentLogs = []
        newState.homeScreen.isLoading = false
        newState.homeScreen.initFailure = error
        return newState
    }
}
