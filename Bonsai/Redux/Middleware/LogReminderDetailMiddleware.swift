//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct LogReminderDetailMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            changePushNotificationPreferencesMiddleware(logReminderService: services.logReminderService),
            deleteLogReminderMiddleware(logReminderService: services.logReminderService)
        ]
    }

    private static func changePushNotificationPreferencesMiddleware(logReminderService: LogReminderService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .logReminderDetails(action: .isPushNotificationEnabledDidChange(let isEnabled)):
                // Get log reminder from state
                guard let logReminder = state.logReminderDetails.logReminder else {
                    AppLogging.error("Toggling push notification change but no log reminder is in the state")
                    return
                }
                // Construct a new log reminder
                var newLogReminder = logReminder
                newLogReminder.isPushNotificationEnabled = isEnabled
                logReminderService.saveOrUpdateLogReminder(logReminder: newLogReminder)
                    .map { savedReminder in
                        // Reinit state with the new reminder
                        AppAction.logReminderDetails(action: .updateLogReminder(logReminder: savedReminder))
                    }.catch { err in
                        // Failed to save - update state back to original reminder
                        Just(AppAction.logReminderDetails(action: .updateLogReminder(logReminder: logReminder)))
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

    private static func deleteLogReminderMiddleware(logReminderService: LogReminderService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .logReminderDetails(action: .deleteCurrentReminder):
                // Get log reminder from state
                guard let logReminder = state.logReminderDetails.logReminder else {
                    send(AppAction.logReminderDetails(action: .deleteError(error: ServiceError(message: "No log reminder in state"))))
                    return
                }
                // Perform delete
                delete(logReminderService: logReminderService, logReminder: logReminder)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func delete(logReminderService: LogReminderService, logReminder: LogReminder)
                    -> AnyPublisher<AppAction, Never> {
        return logReminderService.deleteLogReminder(logReminder: logReminder)
                .map { deletedReminder in
                    AppAction.logReminderDetails(action: .deleteSuccess(deletedReminder: deletedReminder))
                }.catch { (err) -> Just<AppAction> in
                    Just(AppAction.logReminderDetails(action: .deleteError(error: err)))
                }
                .eraseToAnyPublisher()
    }

}
