//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalState {
    var user: User? = nil
    var isInitializing: Bool = false
    var initError: Error? = nil

    // Global Navigation
    var showModal: Bool {
        get {
            showCreateLogModal || showCreateLogReminderModal
        }
        // Define setter so we can attach as a binding - when we set this to false, we want to reset all modal states to false
        set {
            if !newValue {
                self.showCreateLogModal = false
                self.showCreateLogReminderModal = false
            }
        }
    }
    var showCreateLogModal = false
    var showCreateLogReminderModal = false

    // Permissions
    var hasNotificationPermissions: Bool = false
}
