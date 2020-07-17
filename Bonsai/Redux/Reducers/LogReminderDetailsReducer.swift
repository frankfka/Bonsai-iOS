import Foundation

struct LogReminderDetailsReducer {
    static func reduce(state: AppState, action: LogReminderDetailsAction) -> AppState {
        switch action {
        case let .initState(logReminder):
            return initState(state: state, logReminder: logReminder)
        case let .isPushNotificationEnabledDidChange(isEnabled):
            return isPushNotificationEnabledDidChange(state: state, isEnabled: isEnabled)
        case .skipReminder:
            return skipReminder(state: state)
        case .skipReminderSuccess(let newReminder):
            return skipReminderSuccess(state: state, newReminder: newReminder)
        case .skipReminderSuccessShown:
            return skipReminderSuccessShown(state: state)
        case .skipReminderError(let error):
            return skipReminderError(state: state, error: error)
        case .deleteCurrentReminder:
            return deleteReminder(state: state)
        case .deleteSuccess:
            return deleteSuccess(state: state)
        case let .deleteError(error):
            return deleteError(state: state, error: error)
        case .errorPopupShown:
            return errorPopupShown(state: state)
        case .updateLogReminder(let logReminder):
            return initState(state: state, logReminder: logReminder)
        case .screenDidDismiss:
            return screenDidDismiss(state: state)
        }
    }

    static private func initState(state: AppState, logReminder: LogReminder) -> AppState {
        var newState = state
        // Start in loading with a fresh state
        var logReminderDetailState = LogReminderDetailState()
        logReminderDetailState.logReminder = logReminder
        logReminderDetailState.isPushNotificationEnabled = logReminder.isPushNotificationEnabled
        newState.logReminderDetails = logReminderDetailState
        return newState
    }

    static private func isPushNotificationEnabledDidChange(state: AppState, isEnabled: Bool) -> AppState {
        var newState = state
        newState.logReminderDetails.isPushNotificationEnabled = isEnabled
        return newState
    }

    static private func skipReminder(state: AppState) -> AppState {
        var newState = state
        newState.logReminderDetails.isSkipping = true
        return newState
    }

    static private func skipReminderSuccess(state: AppState, newReminder: LogReminder) -> AppState {
        // Create a new state with the updated reminder
        var newState = initState(state: state, logReminder: newReminder)
        newState.logReminderDetails.skipSuccess = true
        return newState
    }

    static private func skipReminderSuccessShown(state: AppState) -> AppState {
        var newState = state
        newState.logReminderDetails.skipSuccess = false
        return newState
    }

    static private func skipReminderError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.logReminderDetails.isSkipping = false
        newState.logReminderDetails.skipError = error
        return newState
    }

    static private func deleteReminder(state: AppState) -> AppState {
        var newState = state
        newState.logReminderDetails.isDeleting = true
        return newState
    }

    static private func deleteSuccess(state: AppState) -> AppState {
        var newState = state
        newState.logReminderDetails.isDeleting = false
        newState.logReminderDetails.deleteSuccess = true
        return newState
    }
    
    static private func deleteError(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
        var newState = state
        newState.logReminderDetails.deleteError = error
        newState.logReminderDetails.isDeleting = false
        return newState
    }

    static private func errorPopupShown(state: AppState) -> AppState {
        // Reset all errors
        var newState = state
        newState.logReminderDetails.deleteError = nil
        return newState
    }
    
    static private func screenDidDismiss(state: AppState) -> AppState {
        var newState = state
        // Completely reset the state
        newState.logReminderDetails = LogReminderDetailState()
        return newState
    }
    
}
