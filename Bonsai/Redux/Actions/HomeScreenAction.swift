//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum HomeScreenAction {
    case screenDidShow
    case initializeData
    case dataLoadSuccess(recentLogs: [Loggable], logReminders: [LogReminder])
    case dataLoadError(error: Error)
}