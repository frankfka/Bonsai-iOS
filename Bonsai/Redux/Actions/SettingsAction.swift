//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import UIKit

enum SettingsAction {
    case linkGoogleAccountPressed(presentingVc: UIViewController)
    // User first signs in with Google
    case googleSignedIn(googleAccount: User.FirebaseGoogleAccount)
    case googleSignInError(error: Error)
    // We then see if an existing account is already linked
    case findLinkedGoogleAccountSuccess(user: User?, googleAccount: User.FirebaseGoogleAccount)
    case findLinkedGoogleAccountError(error: Error)
    // We currently do not support merges, so either user links for the first time, or we're changing the local user ID
    case linkGoogleAccount(googleAccount: User.FirebaseGoogleAccount)
    case linkGoogleAccountSuccess(newUserWithGoogleAccount: User) // Linked for the first time
    case linkGoogleAccountError(error: Error)
    case existingUserWithGoogleAccountFound(existingUser: User)
    case restoreLinkedAccount(userToRestore: User) // Dispatch when user chooses to restore to an existing linked account
    case restoreLinkedAccountSuccess(restoredUser: User)
    case restoreLinkedAccountError(error: Error)
    case unlinkGoogleAccount
    case unlinkGoogleAccountSuccess(newUser: User)
    case unlinkGoogleAccountError(error: Error)
    case cancelRestoreLinkedAccount
    case errorPopupShown
    case successPopupShown
}
