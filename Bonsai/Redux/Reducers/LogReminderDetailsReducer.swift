import Foundation

struct LogReminderDetailsReducer {
    static func reduce(state: AppState, action: LogReminderDetailsAction) -> AppState {
        switch action {
        case let .initState(logReminder):
            return initState(state: state, logReminder: logReminder)
        case .deleteCurrentLog:
            return deleteLog(state: state)
        case let .deleteSuccess(deletedLog):
            return deleteSuccess(state: state, deletedLog: deletedLog)
        case let .deleteError(error):
            return deleteError(state: state, error: error)
        case .errorPopupShown:
            return errorPopupShown(state: state)
        case .screenDidDismiss:
            return screenDidDismiss(state: state)
        }
    }

    static private func initState(state: AppState, logReminder: LogReminder) -> AppState {
        var newState = state
        // Start in loading with a fresh state
        var logReminderDetailState = LogReminderDetailState()
        logReminderDetailState.logReminder = logReminder
        newState.logReminderDetails = logReminderDetailState
        return newState
    }
    
    static private func deleteLog(state: AppState) -> AppState {
        var newState = state
        newState.logReminderDetails.isDeleting = true
        return newState
    }

    static private func deleteSuccess(state: AppState, deletedLog: Loggable) -> AppState {
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
