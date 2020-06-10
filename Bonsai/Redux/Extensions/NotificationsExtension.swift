//
// Created by Frank Jia on 2020-06-09.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import UserNotifications

// MARK: Extension for notifications
extension AppStore: UNUserNotificationCenterDelegate {

    // Called when notification is supposed to present, but app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert]) // Display notification as regular alert
    }
    // Called when user taps on the notification and launches the app, completionHandler notifies iOS that we are done processing the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // App was opened - We need to show the CreateLogScreen, but if app was not previously open, state is not yet initialized
            // So, we wait until we have initialized using a timer
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if !self.state.global.isInitializing {
                    // Done waiting, cancel the timer
                    timer.invalidate()
                    guard self.state.global.initError == nil && self.state.global.user != nil else {
                        // Load error, so skip
                        return
                    }
                    let logReminderId = LogReminder.idFromNotificationId(response.notification.request.identifier)
                    self.services.logReminderService.getLogReminder(with: logReminderId)
                        .sink(receiveCompletion: { completion in
                            if case let .failure(err) = completion {
                                AppLogging.error("Error retrieving log reminder for notification: \(err)")
                            }
                        }, receiveValue: { reminder in
                            if let reminder = reminder {
                                self.send(.createLog(action: .beginInitFromLogReminder(logReminder: reminder)))
                                self.showCreateLogModal = true
                            } else {
                                AppLogging.error("No log reminder found for notification ID \(response.notification.request.identifier)")
                            }
                        })
                        .store(in: &self.cancellables)
                }
            }
        default:
            break
        }
        completionHandler()
    }
}