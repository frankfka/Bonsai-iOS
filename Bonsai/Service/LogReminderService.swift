//
// Created by Frank Jia on 2020-03-10.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

protocol LogReminderService {
    func getLogReminders() -> ServicePublisher<[LogReminder]>
    // Called when user completes a log reminder
    func completeLogReminder(logReminder: LogReminder) -> (publisher: ServicePublisher<LogReminder>, didDelete: Bool)
    func saveLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder>
    func deleteLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder>
}

class LogReminderServiceImpl: LogReminderService {

    private let db: DatabaseService

    init(db: DatabaseService) {
        self.db = db
    }

    func getLogReminders() -> ServicePublisher<[LogReminder]> {
        return self.db.getLogReminders()
    }

    func completeLogReminder(logReminder: LogReminder) -> (publisher: ServicePublisher<LogReminder>, didDelete: Bool) {
        if let recurringInterval = logReminder.reminderInterval {
            // Update the log reminder
            var newLogReminder = logReminder
            newLogReminder.reminderDate = newLogReminder.reminderDate.addingTimeInterval(recurringInterval)
            return (self.db.saveOrUpdateLogReminder(newLogReminder), false)
        } else {
            // Not recurring, just delete
            return (self.db.deleteLogReminder(logReminder), true)
        }
    }

    // TODO: Need to check for permissions if reminders are set, then create the notification reminder as well
    func saveLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder> {
        return self.db.saveOrUpdateLogReminder(logReminder)
    }

    func deleteLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder> {
        return self.db.deleteLogReminder(logReminder)
    }

}