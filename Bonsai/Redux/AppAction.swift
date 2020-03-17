//
//  Actions.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

enum AppAction {
    case global(action: GlobalAction)
    case globalLog(action: GlobalLogAction)
    case globalLogReminder(action: GlobalLogReminderAction)
    case homeScreen(action: HomeScreenAction)
    case viewLog(action: ViewLogsAction)
    case logDetails(action: LogDetailsAction)
    case logReminderDetails(action: LogReminderDetailsAction)
    case settings(action: SettingsAction)
    case createLog(action: CreateLogAction)
    case createLogReminder(action: CreateLogReminderAction)
}