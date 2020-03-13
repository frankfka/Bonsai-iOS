//
// Created by Frank Jia on 2020-01-15.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

struct PreviewLogReminders {

    static let overdue = LogReminder(
            id: "1",
            reminderDate: Date().addingTimeInterval(-TimeInterval.day),
            reminderInterval: nil,
            templateLoggable: PreviewLoggables.medication
    )

    static let notOverdue = LogReminder(
            id: "2",
            reminderDate: Date().addingTimeInterval(TimeInterval.day),
            reminderInterval: nil,
            templateLoggable: PreviewLoggables.notes
    )

}