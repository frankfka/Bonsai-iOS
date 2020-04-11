//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum ViewLogsAction: LoggableAction {
    case screenDidShow
    case dataLoadError(error: Error)

    case viewTypeChanged(isViewByDate: Bool)
    // View by date
    case fetchDataByDate(date: Date)
    case selectedDateChanged(date: Date) // Only support 1 day for now
    case dataLoadSuccessForDate(logs: [Loggable], date: Date)
    // View all
    case fetchAllLogData(limit: Int)
    case dataLoadSuccessForAllLogs(logs: [Loggable])
}