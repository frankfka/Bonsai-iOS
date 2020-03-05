//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct GlobalLogsMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            mapActionsToGlobalLogActionMiddleware()
        ]
    }

    // MARK: Middleware to map individual screen actions to global log actions
    private static func mapActionsToGlobalLogActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            // Home Screen
            case .homeScreen(action: let .dataLoadSuccess(recentLogs)):
                send(.globalLog(action: .insertMany(logs: recentLogs)))
            // Create Log
            case .createLog(action: let .onCreateLogSuccess(newLog)):
                send(.globalLog(action: .insert(log: newLog)))
            // View Logs
            case .viewLog(action: let .dataLoadSuccess(logs, date)):
                send(.globalLog(action: .replace(logs: logs, date: date)))
                send(.globalLog(action: .markAsRetrieved(date: date)))
            // View Log Detail
            case .logDetails(action: let .deleteSuccess(deletedLog)):
                send(.globalLog(action: .delete(log: deletedLog)))
            default:
                break
            }
        }
    }
}