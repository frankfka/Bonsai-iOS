//
//  AppReducer.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

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
    var createLog: CreateLogState

    init() {
        createLog = CreateLogState()
        global = GlobalState()
    }
}

func appReducer(state: inout AppState, action: AppAction) {
    switch action {
    case let .global(action):
        GlobalReducer.reduce(state: &state, action: action)
    case let .createLog(action):
        CreateLogReducer.reduce(state: &state, action: action)
    }
}

// Global services wrapper
private let services = Services()
let appMiddleware: [Middleware<AppState>] = [
    appInitMiddleware(userService: services.userService),
    createLogSearchMiddleware(logService: services.logService)
]