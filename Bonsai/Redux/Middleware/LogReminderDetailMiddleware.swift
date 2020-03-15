//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct LogReminderDetailMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            deleteLogReminderMiddleware(logReminderService: services.logReminderService)
        ]
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
                .map { _ in
                    return AppAction.logReminderDetails(action: .deleteSuccess(deletedReminder: logReminder))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.logReminderDetails(action: .deleteError(error: err)))
                }
                .eraseToAnyPublisher()
    }

}
