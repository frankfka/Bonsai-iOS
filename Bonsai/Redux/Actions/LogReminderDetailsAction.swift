//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum LogReminderDetailsAction: LoggableAction {
    case initState(logReminder: LogReminder)
    case deleteCurrentLog
    case deleteSuccess(deletedLog: Loggable)
    case deleteError(error: Error)
    case errorPopupShown
    case screenDidDismiss
}