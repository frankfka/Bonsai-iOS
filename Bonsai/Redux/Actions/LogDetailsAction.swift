//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum LogDetailsAction: LoggableAction {
    // Initialize loggable details
    case initState(loggable: Loggable)
    case fetchLogDataSuccess(loggable: Loggable)
    case fetchLogDataError(error: Error)
    // Initialize loggable analytics for symptom logs
    case initSymptomLogAnalytics(symptomLog: SymptomLog)
    case initSymptomLogAnalyticsSuccess(result: SymptomSeverityAnalytics)
    case initSymptomLogAnalyticsFailure(error: Error)
    // Actions
    case deleteCurrentLog
    case deleteSuccess(deletedLog: Loggable)
    case deleteError(error: Error)
    // Screen states
    case errorPopupShown
    case screenDidDismiss
}