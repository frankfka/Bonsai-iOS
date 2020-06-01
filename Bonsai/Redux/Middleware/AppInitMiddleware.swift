//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct AppInitMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            appInitUserMiddleware(userService: services.userService),

            // Notifications
            cancelDeliveredNotificationsMiddleware(notificationService: services.notificationService),
            getNotificationPermissionsOnAppLaunchMiddleware(notificationService: services.notificationService),
        ]
    }

    // MARK: Retrieve user details
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
                        AppLogging.info("Failed to get user \(userId): \(err)")
                        if let reason = err.reason, reason == ServiceError.DoesNotExistInDatabaseError {
                            UserDefaults.standard.removeObject(forKey: UserConstants.UserDefaultsUserIdKey)
                            AppLogging.info("Removing ID \(userId) from user defaults")
                        }
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

    // MARK: Cancel delivered notifications
    private static func cancelDeliveredNotificationsMiddleware(notificationService: NotificationService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .global(action: .appDidLaunch):
                notificationService.removeAllDeliveredNotifications()
            default:
                break
            }
        }
    }

    // MARK: Get notification permissions
    private static func getNotificationPermissionsOnAppLaunchMiddleware(notificationService: NotificationService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .global(action: .initSuccess):
                notificationService.checkForNotificationPermission()
                    .map { hasPermission in
                        AppAction.global(action: .notificationPermissionsInit(isEnabled: hasPermission))
                    }
                    .catch { err in
                        Just(AppAction.global(action: .errorProcessingNotificationPermissions(error: err)))
                    }
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }

}
