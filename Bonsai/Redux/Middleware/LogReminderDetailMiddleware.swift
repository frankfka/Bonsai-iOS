//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct LogReminderDetailMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            deleteLogReminderMiddleware(logReminderService: services.logReminderService, notificationService: services.notificationService)
        ]
    }

    private static func deleteLogReminderMiddleware(logReminderService: LogReminderService,
                                                    notificationService: NotificationService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .logReminderDetails(action: .deleteCurrentReminder):
                // Get log reminder from state
                guard let logReminder = state.logReminderDetails.logReminder else {
                    send(AppAction.logReminderDetails(action: .deleteError(error: ServiceError(message: "No log reminder in state"))))
                    return
                }
                // Perform delete
                delete(logReminderService: logReminderService, notificationService: notificationService, logReminder: logReminder)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func delete(logReminderService: LogReminderService,
                               notificationService: NotificationService,
                               logReminder: LogReminder)
                    -> AnyPublisher<AppAction, Never> {
        return logReminderService.deleteLogReminder(logReminder: logReminder)
                .map { deletedReminder in
                    // Success - Remove notifications
                    notificationService.removeNotifications(for: [deletedReminder])
                    return AppAction.logReminderDetails(action: .deleteSuccess(deletedReminder: deletedReminder))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.logReminderDetails(action: .deleteError(error: err)))
                }
                .eraseToAnyPublisher()
    }

}
