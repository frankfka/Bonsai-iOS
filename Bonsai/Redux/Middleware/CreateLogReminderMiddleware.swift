//
// Created by Frank Jia on 2020-03-10.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Combine
import Foundation
import UserNotifications

struct CreateLogReminderMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            checkPushNotificationPermissionsOnScreenShowMiddleware(notificationService: services.notificationService),
            promptForPermissionsOnEnablingReminderNotifications(notificationService: services.notificationService),
            createLogReminderFromLogReminderStateMiddleware(logReminderService: services.logReminderService),
            scheduleNewNotificationIfNeeded(notificationService: services.notificationService)
        ]
    }

    // MARK: Check permissions on screen show
    private static func checkPushNotificationPermissionsOnScreenShowMiddleware(notificationService: NotificationService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .screenDidShow):
                notificationService.checkForNotificationPermission()
                    .map { isEnabled in
                        return AppAction.global(action: .notificationPermissionsDidChange(isEnabled: isEnabled))
                    }.catch { (err) -> Just<AppAction> in
                        return Just(AppAction.global(action: .errorProcessingNotificationPermissions(error: err)))
                    }
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }

    // MARK: Prompt notifications on enabling notifications
    private static func promptForPermissionsOnEnablingReminderNotifications(notificationService: NotificationService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .isPushNotificationEnabledDidChange(let isEnabled)):
                guard isEnabled else {
                    return
                }
                notificationService.checkAndPromptForNotificationPermission()
                    .map { isEnabled in
                        return AppAction.global(action: .notificationPermissionsDidChange(isEnabled: isEnabled))
                    }.catch { (err) -> Just<AppAction> in
                        return Just(AppAction.global(action: .errorProcessingNotificationPermissions(error: err)))
                    }
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }

    // MARK: Create log reminder from state
    private static func createLogReminderFromLogReminderStateMiddleware
            (logReminderService: LogReminderService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .onSavePressed):
                // Get log reminder from state
                guard let logReminder = getLogReminderFromState(state: state.createLogReminder) else {
                    send(AppAction.createLogReminder(
                        action: .onSaveFailure(error: ServiceError(message: "Could not create log reminder from state")))
                    )
                    return
                }
                // Perform save
                logReminderService.saveLogReminder(logReminder: logReminder)
                    .map { savedLogReminder in
                        return AppAction.createLogReminder(action: .onSaveSuccess(logReminder: savedLogReminder))
                    }.catch { (err) -> Just<AppAction> in
                        return Just(AppAction.createLogReminder(action: .onSaveFailure(error: err)))
                    }
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func getLogReminderFromState(state: CreateLogReminderState) -> LogReminder? {
        guard let templateLog = state.templateLog else {
            return nil
        }
        return LogReminder(
            id: UUID().uuidString,
            reminderDate: state.reminderDate,
            reminderInterval: state.isRecurring ? state.reminderInterval : nil,
            templateLoggable: templateLog,
            isPushNotificationEnabled: state.isPushNotificationEnabled
        )
    }

    // MARK: Schedule notification if needed
    private static func scheduleNewNotificationIfNeeded(notificationService: NotificationService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .onSaveSuccess(let logReminder)):
                // Permissions should have been initialized
                guard logReminder.isPushNotificationEnabled else {
                    return // No action needed
                }
                guard state.global.hasNotificationPermissions else {
                    return // No permissions
                }
                // Schedule a notification
                notificationService.scheduleNotification(for: logReminder)
                    .sink(receiveCompletion: { completion in
                        if case let .failure(err) = completion {
                            AppLogging.error("Error scheduling notification for new reminder: \(err)")
                        }
                    }, receiveValue: { possibleNotificationId in
                        if let possibleNotificationId = possibleNotificationId {
                            AppLogging.info("Scheduled notification for log reminder with notification ID \(possibleNotificationId)")
                        } else {
                            AppLogging.error("Nil notification ID for log reminder with ID \(logReminder.id) - a notification should have been scheduled")
                        }
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }

}
