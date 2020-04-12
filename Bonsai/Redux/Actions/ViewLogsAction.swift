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
    case initDataByDate(date: Date)
    case selectedDateChanged(date: Date) // Only support 1 day for now
    case dataInitSuccessForDate(logs: [Loggable], date: Date)
    // View all
    case initAllLogData
    case loadAdditionalLogs
    case dataLoadSuccessForAllLogs(logs: [Loggable])
    case numToShowChanged(newNumToShow: Int) // When user presses load more
}