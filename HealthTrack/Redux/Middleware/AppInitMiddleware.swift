//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

func appInitMiddleware(userService: UserService) -> Middleware<AppState> {
    return { state, action, cancellables, send in
        switch action {
        case .global(action: .appDidLaunch):
            initUser(userService: userService)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
        default:
            break
        }
    }
}

private func initUser(userService: UserService) -> AnyPublisher<AppAction, Never> {
    if let userId = UserDefaults.standard.string(forKey: UserConstants.UserDefaultsUserIdKey) {
        AppLogging.info("Retrieved user ID \(userId) from local")
        return userService.get(userId: userId)
                .map { user in
                    AppLogging.info("Success getting user \(user.id)")
                    return AppAction.global(action: GlobalAction.initSuccess(user: user))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.info("Failed to get user \(userId). Removing ID from user defaults: \(err)")
                    UserDefaults.standard.removeObject(forKey: UserConstants.UserDefaultsUserIdKey)
                    return Just(AppAction.global(action: GlobalAction.initFailure(error: err)))
                }).eraseToAnyPublisher()
    } else {
        AppLogging.info("No user ID saved locally, creating a new user")
        return userService.save(user: userService.createUser())
                .map { user in
                    AppLogging.info("Created user \(user.id). Adding to user defaults")
                    UserDefaults.standard.set(user.id, forKey: UserConstants.UserDefaultsUserIdKey)
                    return AppAction.global(action: GlobalAction.initSuccess(user: user))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.info("Failed to create user: \(err)")
                    return Just(AppAction.global(action: GlobalAction.initFailure(error: err)))
                }).eraseToAnyPublisher()
    }
}