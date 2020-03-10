//
//  Actions.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import UIKit

enum AppAction {
    case global(action: GlobalAction)
    case globalLog(action: GlobalLogAction)
    case homeScreen(action: HomeScreenAction)
    case viewLog(action: ViewLogsAction)
    case logDetails(action: LogDetailsAction)
    case settings(action: SettingsAction)
    case createLog(action: CreateLogAction)
    case createLogReminder(action: CreateLogReminderAction)
}

enum GlobalAction {
    // On app launch
    case appDidLaunch
    case initSuccess(user: User)
    case initFailure(error: Error)
}

enum GlobalLogAction {
    // Dispatched to change global store of logs
    case insert(log: Loggable)
    case insertMany(logs: [Loggable])
    case replace(logs: [Loggable], date: Date)
    case delete(log: Loggable)
    case markAsRetrieved(date: Date)
    case updateAnalytics
    case analyticsLoadSuccess(analytics: LogAnalytics)
    case analyticsLoadError(error: Error)
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
    case dataLoadSuccess(logs: [Loggable], date: Date)
    case dataLoadError(error: Error)
}

enum LogDetailsAction {
    case initState(loggable: Loggable)
    case fetchLogDataSuccess(loggable: Loggable)
    case fetchLogDataError(error: Error)
    case deleteCurrentLog
    case deleteSuccess(deletedLog: Loggable)
    case deleteError(error: Error)
    case errorPopupShown
    case screenDidDismiss
}

enum SettingsAction {
    case linkGoogleAccountPressed(presentingVc: UIViewController)
    // User first signs in with Google
    case googleSignedIn(googleAccount: User.FirebaseGoogleAccount)
    case googleSignInError(error: Error)
    // We then see if an existing account is already linked
    case findLinkedGoogleAccountSuccess(user: User?, googleAccount: User.FirebaseGoogleAccount)
    case findLinkedGoogleAccountError(error: Error)
    // We currently do not support merges, so either user links for the first time, or we're changing the local user ID
    case linkGoogleAccount(googleAccount: User.FirebaseGoogleAccount)
    case linkGoogleAccountSuccess(newUserWithGoogleAccount: User) // Linked for the first time
    case linkGoogleAccountError(error: Error)
    case existingUserWithGoogleAccountFound(existingUser: User)
    case restoreLinkedAccount(userToRestore: User) // Dispatch when user chooses to restore to an existing linked account
    case restoreLinkedAccountSuccess(restoredUser: User)
    case restoreLinkedAccountError(error: Error)
    case unlinkGoogleAccount
    case unlinkGoogleAccountSuccess(newUser: User)
    case unlinkGoogleAccountError(error: Error)
    case cancelRestoreLinkedAccount
    case errorPopupShown
    case successPopupShown
}

enum CreateLogAction {
    case resetCreateLogState
    case logCategoryDidChange(newIndex: Int)
    case noteDidUpdate(note: String)
    case dateDidChange(newDate: Date)

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
    case onSavePressed
    case onSaveSuccess(newLog: Loggable)
    case onSaveFailure(error: Error)
    case saveErrorShown
}

enum CreateLogReminderAction {
    case initCreateLogReminder(template: Loggable)
    // User Edit Actions
    case isRecurringDidChange(isRecurring: Bool)
    case reminderDateDidChange(newDate: Date)
    case reminderIntervalDidChange(newInterval: TimeInterval)
    // State Actions
    case resetState
    case onSavePressed
    case onSaveSuccess
    case onSaveFailure(error: Error)
    case saveErrorShown
}