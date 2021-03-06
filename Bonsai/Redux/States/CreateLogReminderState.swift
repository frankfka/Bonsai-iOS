//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogReminderState {
    var existingLogReminder: LogReminder? = nil // Initialized if we're editing a log reminder
    var updateLogReminderDetailOnSuccess: Bool = false
    var templateLog: Loggable? = nil
    var reminderDate: Date = Date().addingTimeInterval(.day)
    var isRecurring: Bool = false
    var isPushNotificationEnabled: Bool = false
    var reminderInterval: TimeInterval = .day
    // Whether the log reminder is valid
    var isValidated: Bool {
        templateLog != nil
    }

    // On submit states
    var isSaving: Bool = false
    var saveError: Error? = nil
    var saveSuccess: Bool = false
}
