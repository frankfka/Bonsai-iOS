//
// Created by Frank Jia on 2020-03-10.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

protocol LogReminderService {
    func getLogReminders() -> ServicePublisher<[LogReminder]>
    // Called when user completes a log reminder
    func completeLogReminder(logReminder: LogReminder) -> ServicePublisher<Void>
    func saveLogReminder(logReminder: LogReminder) -> ServicePublisher<Void>
    func deleteLogReminder(logReminder: LogReminder) -> ServicePublisher<Void>
}

class LogReminderServiceImpl: LogReminderService {

    private let db: DatabaseService

    init(db: DatabaseService) {
        self.db = db
    }

    func getLogReminders() -> ServicePublisher<[LogReminder]> {
        return self.db.getLogReminders()
    }

    func completeLogReminder(logReminder: LogReminder) -> ServicePublisher<Void> {
        if let recurringInterval = logReminder.reminderInterval {
            // Update the log reminder
            var newLogReminder = logReminder
            newLogReminder.reminderDate = newLogReminder.reminderDate.addingTimeInterval(recurringInterval)
            return self.db.saveOrUpdateLogReminder(newLogReminder)
        } else {
            // Not recurring, just delete
            return self.db.deleteLogReminder(logReminder)
        }
    }

    func saveLogReminder(logReminder: LogReminder) -> ServicePublisher<Void> {
        return self.db.saveOrUpdateLogReminder(logReminder)
    }

    func deleteLogReminder(logReminder: LogReminder) -> ServicePublisher<Void> {
        return self.db.deleteLogReminder(logReminder)
    }

}