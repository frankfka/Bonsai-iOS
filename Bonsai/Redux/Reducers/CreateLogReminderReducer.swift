//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogReminderReducer {
    static func reduce(state: AppState, action: CreateLogReminderAction) -> AppState {
        switch action {
        case .initCreateLogReminder(let template):
            return initCreateLogReminder(state: state, template: template)
        case .isRecurringDidChange(let isRecurring):
            return isRecurringDidChange(state: state, isRecurring: isRecurring)
        case .isPushNotificationEnabledDidChange(let isEnabled):
            return isPushNotificationEnabledDidChange(state: state, isEnabled: isEnabled)
        case .reminderDateDidChange(let newReminderDate):
            return reminderDateDidChange(state: state, newReminderDate: newReminderDate)
        case .reminderIntervalDidChange(let newInterval):
            return reminderIntervalDidChange(state: state, newInterval: newInterval)
        case .onSavePressed:
            return onSavePressed(state: state)
        case .onSaveSuccess:
            return onSaveSuccess(state: state)
        case .onSaveFailure(let error):
            return onSaveFailure(state: state, error: error)
        case .saveErrorShown:
            return saveErrorShown(state: state)
        case .resetState:
            return resetState(state: state)
        }
    }

    static private func initCreateLogReminder(state: AppState, template: Loggable) -> AppState {
        var newState = state
        var newCreateLogReminderState = CreateLogReminderState()
        newCreateLogReminderState.templateLog = template
        newState.createLogReminder = newCreateLogReminderState
        return newState
    }

    static private func isRecurringDidChange(state: AppState, isRecurring: Bool) -> AppState {
        var newState = state
        newState.createLogReminder.isRecurring = isRecurring
        return newState
    }

    static private func isPushNotificationEnabledDidChange(state: AppState, isEnabled: Bool) -> AppState {
        var newState = state
        newState.createLogReminder.isPushNotificationEnabled = isEnabled
        return newState
    }

    static private func reminderDateDidChange(state: AppState, newReminderDate: Date) -> AppState {
        var newState = state
        newState.createLogReminder.reminderDate = newReminderDate
        return newState
    }

    static private func reminderIntervalDidChange(state: AppState, newInterval: TimeInterval) -> AppState {
        var newState = state
        newState.createLogReminder.reminderInterval = newInterval
        return newState
    }

    static private func onSavePressed(state: AppState) -> AppState {
        var newState = state
        newState.createLogReminder.isSaving = true
        return newState
    }

    static private func onSaveSuccess(state: AppState) -> AppState {
        var newState = state
        newState.createLogReminder.isSaving = false
        newState.createLogReminder.saveSuccess = true
        return newState
    }

    static private func onSaveFailure(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.createLogReminder.isSaving = false
        newState.createLogReminder.saveError = error
        return newState
    }

    static private func saveErrorShown(state: AppState) -> AppState {
        var newState = state
        newState.createLogReminder.saveError = nil
        return newState
    }

    static private func resetState(state: AppState) -> AppState {
        var newState = state
        newState.createLogReminder = CreateLogReminderState()
        return newState
    }

}