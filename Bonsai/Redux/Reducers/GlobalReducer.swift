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
        // Permissions
        case let .notificationPermissionsDidChange(isEnabled):
            return notificationPermissionsDidChange(state: state, isEnabled: isEnabled)
        case let .notificationPermissionsInit(isEnabled):
            return notificationPermissionsDidChange(state: state, isEnabled: isEnabled)
        case let .errorProcessingNotificationPermissions(error):
            return errorProcessingNotificationPermissions(state: state, error: error)
        }
    }

    static private func appDidLaunch(state: AppState) -> AppState {
        // Begin with a fresh state
        var newState = AppState()
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
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.global.isInitializing = false
        newState.global.initError = error
        return newState
    }

    static private func notificationPermissionsDidChange(state: AppState, isEnabled: Bool) -> AppState {
        var newState = state
        newState.global.hasNotificationPermissions = isEnabled
        return newState
    }

    static private func errorProcessingNotificationPermissions(state: AppState, error: Error) -> AppState {
        var newState = state
        AppLogging.error("Failure Action: \(error)")
        newState.global.hasNotificationPermissions = false // Assume no notification permissions
        return newState
    }

}