//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum CreateLogReminderAction: LoggableAction {
    case initCreateLogReminder(template: Loggable)
    // Second argument true if we want to update the state of log reminder detail when we finish editing
    case initEditLogReminder(existingReminder: LogReminder, updateLogReminderDetailOnSuccess: Bool)
    case screenDidShow
    // User Edit Actions
    case isRecurringDidChange(isRecurring: Bool)
    case isPushNotificationEnabledDidChange(isEnabled: Bool)
    case reminderDateDidChange(newDate: Date)
    case reminderIntervalDidChange(newInterval: TimeInterval)
    // State Actions
    case resetState
    case onSavePressed
    case onSaveSuccess(logReminder: LogReminder)
    case onSaveFailure(error: Error)
    case saveErrorShown
}
