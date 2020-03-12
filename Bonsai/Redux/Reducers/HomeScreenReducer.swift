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
        case .dataLoadSuccess:
            return dataLoadSuccess(state: state)
        case .dataLoadError(let error):
            return dataLoadError(state: state, error: error)
        }
    }

    static private func initializeData(state: AppState) -> AppState {
        var newState = state
        newState.homeScreen.isLoading = true
        return newState
    }

    static private func dataLoadSuccess(state: AppState) -> AppState {
        var newState = state
        newState.homeScreen.isLoading = false
        newState.homeScreen.initSuccess = true
        return newState
    }

    static private func dataLoadError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.homeScreen.isLoading = false
        newState.homeScreen.initFailure = error
        return newState
    }
}
