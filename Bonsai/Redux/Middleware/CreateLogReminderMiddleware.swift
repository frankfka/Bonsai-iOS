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
            changePushNotificationSettingMiddleware(),
            createLogReminderFromLogReminderStateMiddleware(logReminderService: services.logReminderService)
        ]
    }

    // MARK: Check permissions
    private static func changePushNotificationSettingMiddleware() -> Middleware<AppState> {


        func requestPermission(onComplete: @escaping BoolCallback) -> Void {
            print("Requesting")
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert]) { granted, error in
                    guard error == nil else {
                        AppLogging.warn("Error requesting notification authorization: \(String(describing: error))")
                        onComplete(false)
                        return
                    }
                    if granted && error == nil {
                        print("granted")
                        onComplete(true)
                    } else {
                        print("Denied")
                        onComplete(false)
                    }
                }
        }

        return { state, action, cancellables, send in
            switch action {
            case .createLogReminder(action: .isPushNotificationEnabledDidChange(let isEnabled)):
                guard isEnabled else {
                    // Don't need to check permissions if we're disabling
                    return
                }
                // TODO: if no permission, dispatch action to display warning
                requestPermission { didGetPermission in

                }
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
