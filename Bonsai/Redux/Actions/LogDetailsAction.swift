//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum LogDetailsAction: LoggableAction {
    case initState(loggable: Loggable)
    case fetchLogDataSuccess(loggable: Loggable)
    case fetchLogDataError(error: Error)
    case deleteCurrentLog
    case deleteSuccess(deletedLog: Loggable)
    case deleteError(error: Error)
    case errorPopupShown
    case screenDidDismiss
}