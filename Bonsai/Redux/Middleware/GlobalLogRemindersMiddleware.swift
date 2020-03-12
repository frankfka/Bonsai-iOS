//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct GlobalLogRemindersMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            mapActionsToGlobalLogReminderActionMiddleware()
        ]
    }

    private static func mapActionsToGlobalLogReminderActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            // Home Screen
            case .homeScreen(action: let .dataLoadSuccess(_, logReminders)):
                send(.globalLogReminder(action: .addOrUpdateMany(logReminders)))
            default:
                break
            }
        }
    }
}