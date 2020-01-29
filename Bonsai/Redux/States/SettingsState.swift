//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct SettingsState {
    var isLoading: Bool = false
    var googleSignInError: Error? = nil
    var linkGoogleAccountError: Error? = nil
    var linkGoogleAccountSuccess: Bool = false
    var accountRestoreSuccess: Bool = false
    var existingUserWithLinkedGoogleAccount: User? = nil
}
