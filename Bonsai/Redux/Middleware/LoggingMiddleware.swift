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
            return "Global: \(action.actionName)"
        case let .homeScreen(action):
            return "Home Screen: \(action.actionName)"
        case let .viewLog(action):
            return "View Log: \(action.actionName)"
        case let.createLog(action):
            return "Create Log: \(action.actionName)"
        }
    }
}

// TODO: get this simpler/figured out
// https://stackoverflow.com/questions/35374588/get-enumeration-name-when-using-associated-values
extension GlobalAction {
    var actionName: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return String(describing: self)
        }
    }
}
extension HomeScreenAction {
    var actionName: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return String(describing: self)
        }
    }
}
extension ViewLogsAction {
    var actionName: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return String(describing: self)
        }
    }
}
extension CreateLogAction {
    var actionName: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return String(describing: self)
        }
    }
}
