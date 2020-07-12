//
// Created by Frank Jia on 2020-03-10.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Combine
import Foundation

struct CreateLogReminderMiddleware {

    static func middleware(services: AppServices) -> [Middleware<AppState>] {
        return [
            checkPushNotificationPermissionsOnScreenShowMiddleware(notificationService: services.notificationService),
            promptForPermissionsOnEnablingReminderNotifications(notificationService: services.notificationService),
            createLogReminderFromLogReminderStateMiddleware(logReminderService: services.logReminderService),
            updateLogReminderDetailOnEditLogReminderSuccessMiddleware()
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

    // MARK: Prompt notifications on enabling notifications - will not prompt after first prompt
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
        { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .onSavePressed):
                // Get log reminder from state
                guard let logReminder = getLogReminderFromState(state: state.createLogReminder) else {
                    send(AppAction.createLogReminder(
                        action: .onSaveFailure(error: ServiceError(message: "Could not create log reminder from state")))
                    )
                    return
                }
                // Perform save - this will schedule all the required notifications as well
                logReminderService.saveOrUpdateLogReminder(logReminder: logReminder)
                    .map { savedLogReminder in
                        AppAction.createLogReminder(action: .onSaveSuccess(logReminder: savedLogReminder))
                    }.catch { (err) -> Just<AppAction> in
                        Just(AppAction.createLogReminder(action: .onSaveFailure(error: err)))
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
        // Get ID from existing reminder (if editing) or generate a new one
        let reminderId = state.existingLogReminder?.id ?? UUID().uuidString
        return LogReminder(
            id: reminderId,
            reminderDate: state.reminderDate,
            reminderInterval: state.isRecurring ? state.reminderInterval : nil,
            templateLoggable: templateLog,
            isPushNotificationEnabled: state.isPushNotificationEnabled
        )
    }

    private static func updateLogReminderDetailOnEditLogReminderSuccessMiddleware() -> Middleware<AppState> {
        { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .onSaveSuccess(let updatedReminder)):
                if state.createLogReminder.existingLogReminder != nil && state.createLogReminder.updateLogReminderDetailOnSuccess {
                    // Update the log reminder detail state
                    send(.logReminderDetails(action: .initState(logReminder: updatedReminder)))
                }
            default:
                break
            }
        }
    }

}
