//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct SettingsMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            linkGoogleAccountPressedMiddleware(userService: services.userService),
            linkGoogleAccountSuccessMiddleware(userService: services.userService),
            searchForExistingUsersSuccessMiddleware(),
            linkGoogleAccountMiddleware(userService: services.userService),
            restoreUserMiddleware(userService: services.userService),
            unlinkGoogleAccountMiddleware(userService: services.userService)
        ]
    }

    // User initiated flow for linking Google account - send the presentingVC to show the Google Sign In modal
    private static func linkGoogleAccountPressedMiddleware(userService: UserService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .settings(action: let .linkGoogleAccountPressed(presentingVc)):
                // Call user service to begin sign in process
                userService.signInWithGoogle(presentingVc: presentingVc)
            default:
                break
            }
        }
    }

    // User signed in successfully, look for existing users with linked account
    private static func linkGoogleAccountSuccessMiddleware(userService: UserService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .settings(action: let .googleSignedIn(googleAccount)):
                // Look for existing linked Google Accounts
                linkGoogleAccountSuccessMiddleware(googleAccount: googleAccount, userService: userService)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func linkGoogleAccountSuccessMiddleware(googleAccount: User.FirebaseGoogleAccount, userService: UserService) -> AnyPublisher<AppAction, Never> {
        userService.findExistingUserWithGoogleAccount(googleAccount: googleAccount)
                .map { foundUser in
                    AppLogging.info("Success querying matching users with google ID \(googleAccount.id): \(foundUser == nil ? "No user" : "user") found")
                    return AppAction.settings(action: .findLinkedGoogleAccountSuccess(user: foundUser, googleAccount: googleAccount))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.error("Error querying matching users with google ID \(googleAccount.id): \(err)")
                    return Just(AppAction.settings(action: .findLinkedGoogleAccountError(error: err)))
                }).eraseToAnyPublisher()
    }

    // Search for existing users was successful, dispatch the correct action from the result
    private static func searchForExistingUsersSuccessMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .settings(action: let .findLinkedGoogleAccountSuccess(user, googleAccount)):
                if let user = user {
                    // Existing user found - update state to ask users whether they want to restore
                    send(.settings(action: .existingUserWithGoogleAccountFound(existingUser: user)))
                } else {
                    // No user found, update user profile info with the Google Account
                    send(.settings(action: .linkGoogleAccount(googleAccount: googleAccount)))
                }
            default:
                break
            }
        }
    }

    // Link Google Account - no linked user found, so update the current user with the Google ID
    private static func linkGoogleAccountMiddleware(userService: UserService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .settings(action: let .linkGoogleAccount(googleAccount)):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when linking Google account")
                }
                linkGoogleAccountMiddleware(user: user, googleAccount: googleAccount, userService: userService)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func linkGoogleAccountMiddleware(user: User, googleAccount: User.FirebaseGoogleAccount, userService: UserService) -> AnyPublisher<AppAction, Never> {
        var newUser = user
        newUser.linkedFirebaseGoogleAccount = googleAccount
        return userService.save(user: newUser)
                .map {
                    AppLogging.info("Google Account linked successfully")
                    return AppAction.settings(action: .linkGoogleAccountSuccess(newUserWithGoogleAccount: newUser))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.error("Error saving linked Google Account to user: \(err)")
                    return Just(AppAction.settings(action: .linkGoogleAccountError(error: err)))
                }).eraseToAnyPublisher()
    }

    // User initiated restore
    private static func restoreUserMiddleware(userService: UserService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .settings(action: let .restoreLinkedAccount(userToRestore)):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when linking Google account")
                }
                restoreUserMiddleware(currentUser: user, userToRestore: userToRestore, userService: userService)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func restoreUserMiddleware(currentUser: User, userToRestore: User, userService: UserService) -> AnyPublisher<AppAction, Never> {
        return userService.restoreUser(currentUser: currentUser, userToRestore: userToRestore)
                .map {
                    AppAction.settings(action: .restoreLinkedAccountSuccess(restoredUser: userToRestore))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.error("Error restoring user \(userToRestore.id): \(err)")
                    return Just(AppAction.settings(action: .restoreLinkedAccountError(error: err)))
                }).eraseToAnyPublisher()
    }

    // Unlink the Google account from the user
    private static func unlinkGoogleAccountMiddleware(userService: UserService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .settings(action: .unlinkGoogleAccount):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when linking Google account")
                }
                unlinkGoogleAccountMiddleware(user: user, userService: userService)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func unlinkGoogleAccountMiddleware(user: User, userService: UserService) -> AnyPublisher<AppAction, Never> {
        var newUser = user
        newUser.linkedFirebaseGoogleAccount = nil
        return userService.save(user: newUser)
                .map {
                    AppAction.settings(action: .unlinkGoogleAccountSuccess(newUser: newUser))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.error("Error unlinking Google account from user \(newUser.id): \(err)")
                    return Just(AppAction.settings(action: .unlinkGoogleAccountError(error: err)))
                }).eraseToAnyPublisher()
    }

}
