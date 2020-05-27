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
            changePushNotificationSettingMiddleware(notificationService: services.notificationService),
            createLogReminderFromLogReminderStateMiddleware(logReminderService: services.logReminderService)
        ]
    }

    // MARK: Check permissions
    private static func changePushNotificationSettingMiddleware(notificationService: NotificationService) -> Middleware<AppState> {
        // TODO: Let's rethink this - we want to prompt when appropriate..
        return { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .screenDidShow):
                notificationService.checkAndPromptForNotificationPermission()
                    .map { isEnabled in
                        return AppAction.global(action: .notificationPermissionsDidChange(isEnabled: isEnabled))
                    }.catch { (err) -> Just<AppAction> in
                        return Just(AppAction.global(action: .errorRequestingNotificationPermissions(error: err)))
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

    // MARK: Create
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
                save(logReminderService: logReminderService, logReminder: logReminder)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func save(logReminderService: LogReminderService, logReminder: LogReminder)
                    -> AnyPublisher<AppAction, Never> {
        return logReminderService.saveLogReminder(logReminder: logReminder)
                .map { savedLogReminder in
                    return AppAction.createLogReminder(action: .onSaveSuccess(logReminder: savedLogReminder))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.createLogReminder(action: .onSaveFailure(error: err)))
                }
                .eraseToAnyPublisher()
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

}
