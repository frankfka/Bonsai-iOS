//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum ViewLogsAction: LoggableAction {
    case fetchData(date: Date)
    case dataLoadSuccess(logs: [Loggable], date: Date)
    case dataLoadError(error: Error)

    case viewTypeChanged(isViewByDate: Bool)

    // View by date
    case selectedDateChanged(date: Date) // Only support 1 day for now
}