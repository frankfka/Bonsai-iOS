//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum GlobalLogReminderAction {
    case addOrUpdate(_ logReminder: LogReminder)
    case addOrUpdateMany(_ logReminders: [LogReminder])
    case remove(_ logReminder: LogReminder)
}