//
// Created by Frank Jia on 2020-03-10.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

protocol LogReminderService {
    func getLogReminders() -> ServicePublisher<[LogReminder]>
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

    func saveLogReminder(logReminder: LogReminder) -> ServicePublisher<Void> {
        return self.db.saveLogReminder(logReminder)
    }

    func deleteLogReminder(logReminder: LogReminder) -> ServicePublisher<Void> {
        return self.db.deleteLogReminder(logReminder)
    }

}