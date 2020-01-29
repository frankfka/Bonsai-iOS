//
// Created by Frank Jia on 2019-12-30.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct AppReducer {
    static func reduce(state: AppState, action: AppAction) -> AppState {
        switch action {
        case let .global(action):
            return GlobalReducer.reduce(state: state, action: action)
        case let .homeScreen(action):
            return HomeScreenReducer.reduce(state: state, action: action)
        case let .viewLog(action):
            return ViewLogsReducer.reduce(state: state, action: action)
        case let .logDetails(action):
            return LogDetailsReducer.reduce(state: state, action: action)
        case let .settings(action):
            return SettingsReducer.reduce(state: state, action: action)
        case let .createLog(action):
            return CreateLogReducer.reduce(state: state, action: action)
        }
    }
}
