//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

func loggingMiddleware() -> Middleware<AppState> {
    return { _, action, _, _ in
        AppLogging.debug("Dispatch \(action.logName)")
    }
}

extension AppAction {
    var logName: String {
        switch self {
        case let .global(action):
            return "Global: \(action.loggableActionName)"
        case let .globalLog(action):
            return "Global Log: \(action.loggableActionName)"
        case let .globalLogReminder(action):
            return "Global Log Reminder: \(action.loggableActionName)"
        case let .homeScreen(action):
            return "Home Screen: \(action.loggableActionName)"
        case let .viewLog(action):
            return "View Log: \(action.loggableActionName)"
        case let .logDetails(action):
            return "Log Details: \(action.loggableActionName)"
        case let .logReminderDetails(action):
            return "Log Reminder Details: \(action.loggableActionName)"
        case let .settings(action):
            return "Settings: \(action.loggableActionName)"
        case let.createLog(action):
            return "Create Log: \(action.loggableActionName)"
        case let.createLogReminder(action):
            return "Create Log Reminder: \(action.loggableActionName)"
        }
    }
}

// https://stackoverflow.com/questions/35374588/get-enumeration-name-when-using-associated-values
protocol LoggableAction {}
extension LoggableAction {
    var loggableActionName: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return String(describing: self)
        }
    }
}
