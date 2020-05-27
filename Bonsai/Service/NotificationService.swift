//
// Created by Frank Jia on 2020-05-25.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import UserNotifications
import Combine

class NotificationService {

    // TODO: need a simple check function so we can update global state instead
    func checkAndPromptForNotificationPermission() -> ServicePublisher<Bool> {
        let future = ServiceFuture<Bool> { promise in
            self.checkAndPromptForNotificationPermission { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
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

    func createNewNotification(for logReminder: LogReminder) -> ServicePublisher<Void> {
        let future = ServiceFuture<Void> { promise in
            self.createNewNotification(for: logReminder) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func createNewNotification(for logReminder: LogReminder, onComplete: @escaping ServiceCallback<Void>) {
        let content = logReminder.toNotificationContent()
        let trigger = logReminder.toNotificationTrigger()
        let request = UNNotificationRequest(identifier: logReminder.notificationId, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { err in
            if let err = err {
                onComplete(.failure(ServiceError(message: "Could not create notification for log reminder", wrappedError: err)))
            } else {
                onComplete(.success(()))
            }
        }
    }

    // TODO: Need to schedule the next notification

    // TODO: remove existing notifications, etc

}

private extension LogReminder {
    var notificationId: String { self.id }
    func toNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Log Reminder"
        content.body = "It's time to create a new \(self.templateLoggable.category.displayValue()) log for: \(self.templateLoggable.title)"
        return content
    }
    func toNotificationTrigger() -> UNNotificationTrigger {
        // TODO: Looks like we'll unfortunately need to hack around to do this: https://stackoverflow.com/questions/46070648/trigger-uilocalnotification-for-every-14-days-fortnightly-swift
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.reminderDate)
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    }
}
