//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct SettingsState {
    var isLoading: Bool = false

    // External Google account
    var googleSignInError: Error? = nil
    var linkGoogleAccountError: Error? = nil
    var linkGoogleAccountSuccess: Bool = false
    var unlinkGoogleAccountSuccess: Bool = false
    var unlinkGoogleAccountError: Error? = nil
    var accountRestoreSuccess: Bool = false
    var existingUserWithLinkedGoogleAccount: User? = nil

    // User Preferences
    var settingsDidChange: Bool = false // Indicates whether user settings have changed
    var savedSettings: User.Settings = User.Settings()
}
