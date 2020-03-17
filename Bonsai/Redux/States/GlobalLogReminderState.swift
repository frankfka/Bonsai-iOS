//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalLogReminderState {
    // All log reminders
    var logReminders: Set<LogReminder> = []
    // All log reminders sorted by chronological order (earliest reminder first)
    var sortedLogReminders: [LogReminder] {
        logReminders.sorted { one, other in
            one.reminderDate < other.reminderDate
        }
    }
}
