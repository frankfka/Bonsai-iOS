//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct LogReminderDetailState {
    var logReminder: LogReminder? = nil
    // This reflects the user selection on the screen, which may NOT be the same as what's saved in the log reminder (ex. if save fails)
    var isPushNotificationEnabled: Bool = false
    var isDeleting: Bool = false
    var deleteSuccess: Bool = false
    var deleteError: Error? = nil
}
