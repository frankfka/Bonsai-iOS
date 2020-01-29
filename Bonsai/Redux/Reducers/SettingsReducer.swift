//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct SettingsReducer {
    static func reduce(state: AppState, action: SettingsAction) -> AppState {
        switch action {
        // Social Linking
        case .linkGoogleAccountPressed:
            return linkGoogleAccountPressed(state: state)
        case .googleSignedIn:
            // Handled by middleware
            return state
        case let .googleSignInError(error):
            return googleSignInError(state: state, error: error)
        case .findLinkedGoogleAccountSuccess:
            return findLinkedGoogleAccountSuccess(state: state)
        case .findLinkedGoogleAccountError(let error):
            return findLinkedGoogleAccountError(state: state, error: error)
        case .existingUserWithGoogleAccountFound(let existingUser):
            return existingUserWithGoogleAccountFound(state: state, existingUser: existingUser)
        case .linkGoogleAccount:
            return linkGoogleAccount(state: state)
        case let .linkGoogleAccountSuccess(newUserWithGoogleAccount):
            return linkGoogleAccountSuccess(state: state, newUserWithGoogleAccount: newUserWithGoogleAccount)
        case let .linkGoogleAccountError(error):
            return linkGoogleAccountError(state: state, error: error)
        case .restoreLinkedAccount:
            return restoreLinkedAccount(state: state)
        case let .restoreLinkedAccountError(error):
            return restoreLinkedAccountError(state: state, error: error)
        case .cancelRestoreLinkedAccount:
            return cancelRestoreLinkedAccount(state: state)
        case let .restoreLinkedAccountSuccess(restoredUser):
            return restoreLinkedAccountSuccess(state: state, restoredUser: restoredUser)
        case .successPopupShown:
            return successPopupShown(state: state)
        case .errorPopupShown:
            return errorPopupShown(state: state)
    }
    }

    static private func linkGoogleAccountPressed(state: AppState) -> AppState {
        var newState = state
        newState.settings.isLoading = true
        return newState
    }

    static private func googleSignInError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.settings.googleSignInError = error
        newState.settings.isLoading = false
        return newState
    }

    static private func findLinkedGoogleAccountSuccess(state: AppState) -> AppState {
        var newState = state
        newState.settings.isLoading = false
        return newState
    }

    static private func findLinkedGoogleAccountError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.settings.isLoading = false
        newState.settings.linkGoogleAccountError = error
        return newState
    }

    static private func existingUserWithGoogleAccountFound(state: AppState, existingUser: User) -> AppState {
        var newState = state
        newState.settings.existingUserWithLinkedGoogleAccount = existingUser
        return newState
    }

    static private func linkGoogleAccount(state: AppState) -> AppState {
        var newState = state
        newState.settings.isLoading = true
        return newState
    }

    static private func linkGoogleAccountSuccess(state: AppState, newUserWithGoogleAccount: User) -> AppState {
        var newState = state
        newState.settings.linkGoogleAccountSuccess = true
        newState.settings.isLoading = false
        // Update global user with the newly linked account
        newState.global.user = newUserWithGoogleAccount
        return newState
    }

    static private func linkGoogleAccountError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.settings.isLoading = false
        newState.settings.linkGoogleAccountError = error
        return newState
    }

    static private func restoreLinkedAccount(state: AppState) -> AppState {
        var newState = state
        // Loading while we restore the linked account
        newState.settings.isLoading = true
        newState.settings.existingUserWithLinkedGoogleAccount = nil
        return newState
    }

    static private func restoreLinkedAccountError(state: AppState, error: Error) -> AppState {
        var newState = state
        newState.settings.isLoading = false
        newState.settings.linkGoogleAccountError = error
        return newState
    }

    static private func cancelRestoreLinkedAccount(state: AppState) -> AppState {
        var newState = state
        newState.settings.existingUserWithLinkedGoogleAccount = nil
        return newState
    }

    static private func restoreLinkedAccountSuccess(state: AppState, restoredUser: User) -> AppState {
        // Reset entire app state except for Settings - this will trigger a reload
        var newState = AppState()
        newState.settings = state.settings
        newState.global.user = restoredUser
        newState.settings.isLoading = false
        newState.settings.accountRestoreSuccess = true
        return newState
    }

    static private func successPopupShown(state: AppState) -> AppState {
        var newState = state
        newState.settings.accountRestoreSuccess = false
        newState.settings.linkGoogleAccountSuccess = false
        return newState
    }

    static private func errorPopupShown(state: AppState) -> AppState {
        var newState = state
        newState.settings.googleSignInError = nil
        newState.settings.linkGoogleAccountError = nil
        return newState
    }

}
