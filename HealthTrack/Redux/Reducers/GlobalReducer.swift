//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalReducer {
    static func reduce(state: AppState, action: GlobalAction) -> AppState {
        switch action {
        case .appDidLaunch:
            return appDidLaunch(state: state)
        case let .initSuccess(user):
            return initSuccess(state: state, user: user)
        case let .initFailure(error):
            return initFailure(state: state, error: error)
        }
    }

    static private func appDidLaunch(state: AppState) -> AppState {
        var newState = state
        newState.global.isInitializing = true
        return newState
    }

    static private func initSuccess(state: AppState, user: User) -> AppState {
        var newState = state
        newState.global.isInitializing = false
        newState.global.user = user
        return newState
    }

    static private func initFailure(state: AppState, error: Error) -> AppState {
        var newState = state
        newState.global.isInitializing = false
        newState.global.initError = error
        return newState
    }

}