//
// Created by Frank Jia on 2020-05-25.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import UserNotifications
import Combine

class NotificationService {

    // MARK: Check for / optionally prompt for permissions
    func checkForNotificationPermission() -> ServicePublisher<Bool> {
        ServiceFuture<Bool> { promise in
            self.checkForNotificationPermission { result in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }

    private func checkForNotificationPermission(onComplete: @escaping ServiceCallback<Bool>) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            onComplete(.success(settings.authorizationStatus == .authorized))
        }
    }

    func checkAndPromptForNotificationPermission() -> ServicePublisher<Bool> {
        ServiceFuture<Bool> { promise in
            self.checkAndPromptForNotificationPermission { result in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }

    private func checkAndPromptForNotificationPermission(onComplete: @escaping ServiceCallback<Bool>) {
        UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert]) { granted, err in
                    guard err == nil else {
                        onComplete(.failure(ServiceError(message: "Error requesting notification authorization", wrappedError: err)))
                        return
                    }
                    if granted {
                        onComplete(.success(true))
                    } else {
                        onComplete(.success(false))
                    }
                }
    }


    // MARK: Schedule notifications for log reminders if required - should be called on app init
    func scheduleNotificationsIfNeeded(for logReminders: [LogReminder]) -> ServicePublisher<[Bool]> {
        // TODO: check for permissions, then filter for no notifications enabled
        Publishers.MergeMany(logReminders.map {
                    scheduleNotification(for: $0)
                })
                .collect().eraseToAnyPublisher()
    }

    private func scheduleNotification(for logReminder: LogReminder) -> ServicePublisher<Bool> {
        ServiceFuture<Bool> { promise in
            self.scheduleNotification(for: logReminder) { result in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }

    private func scheduleNotification(for logReminder: LogReminder, onComplete: @escaping ServiceCallback<Bool>) {
        guard let trigger = logReminder.toNotificationTrigger() else {
            // No need to schedule notifications for this log reminder
            onComplete(.success(false))
            return
        }
        let content = logReminder.toNotificationContent()
        let request = UNNotificationRequest(identifier: logReminder.notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err {
                onComplete(.failure(ServiceError(message: "Could not create notification for log reminder", wrappedError: err)))
            } else {
                onComplete(.success(true))
            }
        }
    }

    // MARK: Removal of delivered notifications, good practice to remove any notifications delivered when app launches
    func removeDeliveredNotifications(for logReminders: [LogReminder]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: logReminders.map {
            $0.notificationId
        })
    }

    func removeAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

}

private extension LogReminder {
    var notificationId: String {
        self.id
    }

    func toNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Log Reminder"
        content.body = "It's time to create a new \(self.templateLoggable.category.displayValue()) log for: \(self.templateLoggable.title)"
        return content
    }

    // Returns nil if no new notification should be scheduled
    func toNotificationTrigger() -> UNNotificationTrigger? {
        guard self.isPushNotificationEnabled else {
            return nil
        }
        // Find next notification date
        var notificationDate: Date? = nil
        if self.reminderDate > Date() {
            // Schedule for first reminder
            notificationDate = self.reminderDate
        } else if let interval = self.reminderInterval {
            // Schedule for recurring
            let intervalAddition = ceil(Date().timeIntervalSince(self.reminderDate) / interval) * interval
            notificationDate = self.reminderDate.addingTimeInterval(TimeInterval(intervalAddition))
        }
        // Create trigger
        if let notificationDate = notificationDate {
            if notificationDate < Date() {
                // TODO: Remove after testing
                AppLogging.warn("Trying to set notification date to \(notificationDate)")
                fatalError("Trying to set notification date to \(notificationDate)")
            }
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        } else {
            return nil
        }
    }
}
