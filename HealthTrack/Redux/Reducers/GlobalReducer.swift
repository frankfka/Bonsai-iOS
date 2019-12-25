//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalReducer {
    static func reduce(state: AppState, action: GlobalAction) -> AppState {
        var newState = state
        switch action {
        case .appDidLaunch:
            newState.global.isInitializing = true
        case let .initSuccess(user):
            newState.global.isInitializing = false
            newState.global.user = user
        case let .initFailure(error):
            newState.global.isInitializing = false
            newState.global.initError = error
        }
        return newState
    }
}