//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum CreateLogAction: LoggableAction {
    case resetCreateLogState
    case logCategoryDidChange(newIndex: Int)
    case noteDidUpdate(note: String)
    case dateDidChange(newDate: Date)

    // Occurs when "Create Again" is pressed in details, or when user completes a reminder
    case initFromPreviousLog(loggable: Loggable)
    case beginInitFromLogReminder(logReminder: LogReminder)
    case completedInitFromLogReminder(logReminder: LogReminder)

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
    case onSavePressed
    case onSaveSuccess(newLog: Loggable, associatedLogReminder: LogReminder?)
    case onSaveFailure(error: Error)
    case onLogReminderComplete(logReminder: LogReminder, didDelete: Bool)
    case saveErrorShown
}
