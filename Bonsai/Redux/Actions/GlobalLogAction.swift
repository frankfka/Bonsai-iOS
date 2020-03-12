//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum GlobalLogAction {
    // Dispatched to change global store of logs
    case insert(log: Loggable)
    case insertMany(logs: [Loggable])
    case replace(logs: [Loggable], date: Date)
    case delete(log: Loggable)
    case markAsRetrieved(date: Date)
    case updateAnalytics
    case analyticsLoadSuccess(analytics: LogAnalytics)
    case analyticsLoadError(error: Error)
}