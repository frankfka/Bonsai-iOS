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
    case homeScreen(action: HomeScreenAction)
    case viewLog(action: ViewLogsAction)
    case logDetails(action: LogDetailsAction)
    case createLog(action: CreateLogAction)
}

enum GlobalAction {
    // On app launch
    case appDidLaunch
    case initSuccess(user: User)
    case initFailure(error: Error)
}

enum HomeScreenAction {
    case screenDidShow
    case initializeData
    case dataLoadSuccess(recentLogs: [Loggable])
    case dataLoadError(error: Error)
}

enum ViewLogsAction {
    case screenDidShow
    case fetchData(date: Date)
    case selectedDateChanged(date: Date) // Only support 1 day for now
    case dataLoadSuccess(logs: [Loggable])
    case dataLoadError(error: Error)
}

enum LogDetailsAction {
    case initState(loggable: Loggable)
    case fetchLogDataSuccess(loggable: Loggable)
    case fetchLogDataError(error: Error)
    case deleteCurrentLog
    case deleteSuccess(deletedId: String)
    case deleteError(error: Error)
    case errorPopupShown
}

enum CreateLogAction {
    case screenDidShow
    case screenDidDismiss
    case logCategoryDidChange(newIndex: Int)
    case noteDidUpdate(note: String)

    // Occurs when "Create Again" is pressed in details
    case initFromPreviousLog(loggable: Loggable)

    // Search
    case searchQueryDidChange(query: String)
    case searchDidComplete(results: [LogSearchable])
    case searchItemDidSelect(selectedIndex: Int)
    case onAddSearchItemPressed(name: String)
    case onAddSearchItemSuccess(addedItem: LogSearchable)
    case onAddSearchItemFailure(error: Error)
    case onAddSearchResultPopupShown
    case onSearchViewDismiss

    // Mood
    case moodRankSelected(selectedIndex: Int)

    // Medications
    case medicationDosageDidChange(newDosage: String)

    // Nutrition
    case nutritionAmountDidChange(newAmount: String)

    // Symptom
    case symptomSeverityDidChange(encodedValue: Double)

    // Activity
    case activityDurationDidChange(newDuration: TimeInterval)

    // Save
    case onCreateLogPressed
    case onCreateLogSuccess(newLog: Loggable)
    case onCreateLogFailure(error: Error)
    case createErrorShown
}
