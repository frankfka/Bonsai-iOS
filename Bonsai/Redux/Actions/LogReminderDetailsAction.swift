//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum LogReminderDetailsAction: LoggableAction {
    case initState(logReminder: LogReminder)
    case deleteCurrentReminder
    case deleteSuccess(deletedReminder: LogReminder)
    case deleteError(error: Error)
    case errorPopupShown
    case screenDidDismiss
    case isPushNotificationEnabledDidChange(isEnabled: Bool)
    case updateLogReminder(logReminder: LogReminder)
}