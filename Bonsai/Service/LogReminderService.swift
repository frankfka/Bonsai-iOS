//
// Created by Frank Jia on 2020-03-10.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import Combine

protocol LogReminderService {
    func getLogReminder(with id: String) -> ServicePublisher<LogReminder?>
    func getLogReminders() -> ServicePublisher<[LogReminder]>
    // Called when user completes a log reminder
    func completeLogReminder(logReminder: LogReminder) -> (publisher: ServicePublisher<LogReminder>, didDelete: Bool)
    func saveOrUpdateLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder>
    func deleteLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder>
}

class LogReminderServiceImpl: LogReminderService {

    private let db: DatabaseService
    private let notificationService: NotificationService
    private var cancellables: Set<AnyCancellable> = []

    init(db: DatabaseService, notificationService: NotificationService) {
        self.db = db
        self.notificationService = notificationService
    }

    func getLogReminder(with id: String) -> ServicePublisher<LogReminder?> {
        return self.db.getLogReminder(with: id)
    }

    func getLogReminders() -> ServicePublisher<[LogReminder]> {
        return self.db.getLogReminders()
    }

    func completeLogReminder(logReminder: LogReminder) -> (publisher: ServicePublisher<LogReminder>, didDelete: Bool) {
        if let recurringInterval = logReminder.reminderInterval {
            // Update the log reminder
            var newLogReminder = logReminder
            // Calculate the next reminder time (in the future)
            var nextReminderDate = logReminder.reminderDate.addingTimeInterval(recurringInterval)
            let now = Date()
            // Make sure the next reminder time is in the future
            while nextReminderDate < now {
                nextReminderDate.addTimeInterval(recurringInterval)  // We can make this more performant with smart calculations
            }
            newLogReminder.reminderDate = nextReminderDate
            return (self.saveOrUpdateLogReminder(logReminder: newLogReminder), false)
        } else {
            // Not recurring, just delete
            return (self.deleteLogReminder(logReminder: logReminder), true)
        }
    }

    func saveOrUpdateLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder> {
        // Update notifications
        self.db.saveOrUpdateLogReminder(logReminder)
            .map { savedLogReminder -> LogReminder in
                // Update notifications
                self.applyNotificationPreferences(for: savedLogReminder)
                return savedLogReminder // Passthrough
            }
            .eraseToAnyPublisher()
    }

    func deleteLogReminder(logReminder: LogReminder) -> ServicePublisher<LogReminder> {
        return self.db.deleteLogReminder(logReminder)
            .map { deletedReminder -> LogReminder in
                // Remove notifications if delete was successful
                self.notificationService.removeNotifications(for: [deletedReminder])
                return deletedReminder // Passthrough
            }
            .eraseToAnyPublisher()
    }

    // Either schedules or delete notifications for the log reminder
    // We do these silently as it's not critical for app operation
    private func applyNotificationPreferences(for logReminder: LogReminder) {
        if logReminder.isPushNotificationEnabled {
            self.notificationService.scheduleNotificationsIfNeeded(for: [logReminder])
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(err) = completion {
                            AppLogging.error("Error scheduling notifications for log reminder \(logReminder.id): \(err)")
                        }
                    },
                    receiveValue: { notificationIds in
                        if !notificationIds.isEmpty {
                            AppLogging.info("Notification scheduled for log reminder \(logReminder.id)")
                        }
                    }
                )
                .store(in: &self.cancellables)
        } else {
            AppLogging.info("Removing all scheduled notifications for log reminder \(logReminder.id)")
            self.notificationService.removeNotifications(for: [logReminder])
        }
    }

}
