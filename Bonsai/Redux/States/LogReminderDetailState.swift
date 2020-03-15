//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct LogReminderDetailState {
    var logReminder: LogReminder? = nil
    var isDeleting: Bool = false
    var deleteSuccess: Bool = false
    var deleteError: Error? = nil
}
