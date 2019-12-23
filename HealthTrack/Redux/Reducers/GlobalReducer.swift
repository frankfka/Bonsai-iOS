//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalReducer {
    static func reduce(state: inout AppState, action: GlobalAction) {
        switch action {
        case .appDidLaunch:
            state.global.isInitializing = true
        case let .initSuccess(user):
            state.global.isInitializing = false
            state.global.user = user
        case let .initFailure(error):
            state.global.isInitializing = false
            state.global.initError = error
        }
    }
}