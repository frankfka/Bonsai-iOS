//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum CreateLogReminderAction {
    case initCreateLogReminder(template: Loggable)
    // User Edit Actions
    case isRecurringDidChange(isRecurring: Bool)
    case reminderDateDidChange(newDate: Date)
    case reminderIntervalDidChange(newInterval: TimeInterval)
    // State Actions
    case resetState
    case onSavePressed
    case onSaveSuccess
    case onSaveFailure(error: Error)
    case saveErrorShown
}