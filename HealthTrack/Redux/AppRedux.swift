//
//  AppReducer.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct AppError: Error {
    let message: String
    let wrappedError: Error?

    init(message: String, wrappedError: Error? = nil) {
        self.message = message
        self.wrappedError = wrappedError
    }
}

class Services {
    let userService: UserService
    let logService: LogService

    init() {
        // Init serves as dependency management
        let db = FirebaseService()
        userService = UserServiceImpl(db: db)
        logService = LogServiceImpl(db: db)
    }
}

struct AppState {
    var global: GlobalState
    var homeScreen: HomeScreenState
    var createLog: CreateLogState

    init() {
        global = GlobalState()
        homeScreen = HomeScreenState()
        createLog = CreateLogState()
    }
}

func appReducer(state: AppState, action: AppAction) -> AppState {
    switch action {
    case let .global(action):
        return GlobalReducer.reduce(state: state, action: action)
    case let .homeScreen(action):
        return HomeScreenReducer.reduce(state: state, action: action)
    case let .createLog(action):
        return CreateLogReducer.reduce(state: state, action: action)
    }
}

// Global services wrapper
private let services = Services()
// Somewhat hacky way to send actions in our naive redux implementation
func doInMiddleware(_ action: @escaping VoidCallback) {
    DispatchQueue.main.asyncAfter(deadline: .now()) {
        action()
    }
}
let appMiddleware: [Middleware<AppState>] = [
    loggingMiddleware(),
    // App Init
    appInitUserMiddleware(userService: services.userService),
    // Home Screen
    homeScreenDidShowMiddleware(),
    homeScreenInitMiddleware(logService: services.logService),
    // Create log
    createLogAddNewItemMiddleware(logService: services.logService),
    createLogSearchMiddleware(logService: services.logService),
    createLogOnSaveMiddleware(logService: services.logService)
]