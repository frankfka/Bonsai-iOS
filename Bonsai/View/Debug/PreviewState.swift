//
// Created by Frank Jia on 2020-01-15.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

struct PreviewRedux {
    private static let services: AppServices = try! AppServicesImpl() // TODO: Mock app services
    static let initialStore = AppStore(initialState: AppState(), reducer: AppReducer.reduce, services: services)
    static var filledStore: AppStore {
        // Log Details
        var logDetailsState = LogDetailState()
        logDetailsState.loggable = PreviewLoggables.medication
        // Log Reminder Details
        var logReminderDetailsState = LogReminderDetailState()
        logReminderDetailsState.logReminder = PreviewLogReminders.notOverdue
        // State
        var appState = AppState()
        appState.logDetails = logDetailsState
        appState.logReminderDetails = logReminderDetailsState
        return AppStore(initialState: appState, reducer: AppReducer.reduce, services: services)
    }
}
