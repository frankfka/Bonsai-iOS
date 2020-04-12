//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum GlobalLogAction: LoggableAction {
    // Dispatched to change global store of logs
    case insert(logs: [Loggable])
    case replace(logs: [Loggable], date: Date)
    case delete(log: Loggable)
    case markAsRetrieved(dates: [Date])
    case updateAnalytics
    case analyticsLoadSuccess(analytics: LogAnalytics)
    case analyticsLoadError(error: Error)
}