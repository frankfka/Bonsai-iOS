//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct AppInitMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            appInitUserMiddleware(userService: services.userService)
        ]
    }

    private static func appInitUserMiddleware(userService: UserService) -> Middleware<AppState> {
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

    private static func initUser(userService: UserService) -> AnyPublisher<AppAction, Never> {
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
            let newUser = userService.createUser()
            return userService.save(user: newUser)
                    .map {
                        AppLogging.info("Created user \(newUser.id). Adding to user defaults")
                        UserDefaults.standard.set(newUser.id, forKey: UserConstants.UserDefaultsUserIdKey)
                        return AppAction.global(action: GlobalAction.initSuccess(user: newUser))
                    }.catch({ (err) -> Just<AppAction> in
                        AppLogging.info("Failed to create user: \(err)")
                        return Just(AppAction.global(action: GlobalAction.initFailure(error: err)))
                    }).eraseToAnyPublisher()
        }
    }
}