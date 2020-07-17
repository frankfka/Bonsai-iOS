//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct GlobalLogRemindersMiddleware {

    static func middleware(services: AppServices) -> [Middleware<AppState>] {
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
            // Create Log Reminder
            case .createLogReminder(action: let .onSaveSuccess(logReminder)):
                send(.globalLogReminder(action: .addOrUpdate(logReminder)))
            // Log Reminder Details
            case .logReminderDetails(action: let .deleteSuccess(deletedReminder)):
                send(.globalLogReminder(action: .remove(deletedReminder)))
            case .logReminderDetails(action: let .updateLogReminder(logReminder)):
                send(.globalLogReminder(action: .addOrUpdate(logReminder)))
            case .logReminderDetails(action: let .skipReminderSuccess(logReminder)):
                send(.globalLogReminder(action: .addOrUpdate(logReminder)))
            // Create Log
            case .createLog(action: let .onLogReminderComplete(updatedReminder, didDelete)):
                if didDelete {
                    send(.globalLogReminder(action: .remove(updatedReminder)))
                } else {
                    send(.globalLogReminder(action: .addOrUpdate(updatedReminder)))
                }
            default:
                break
            }
        }
    }
}
