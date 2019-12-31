//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

// TODO: split into separate files
struct CreateLogReducer {
    static func reduce(state: AppState, action: CreateLogAction) -> AppState {
        switch action {
        case .screenDidShow:
            return resetCreateLogState(state: state)
        case .screenDidDismiss:
            return resetCreateLogState(state: state)
        case let .logCategoryDidChange(newIndex):
            return logCategoryDidChange(state: state, newIndex: newIndex)
        case let .noteDidUpdate(notes):
            return noteDidUpdate(state: state, newNotes: notes)

        // Search
        case .searchQueryDidChange:
            return searchQueryDidChange(state: state)
        case .searchDidComplete(let results):
            return searchDidComplete(state: state, results: results)
        case .searchItemDidSelect(let index):
            return searchItemDidSelect(state: state, selectedIndex: index)
        case .onAddSearchItemPressed:
            return onAddSearchItemPressed(state: state)
        case let .onAddSearchItemSuccess(addedItem):
            return onAddSearchItemSuccess(state: state, newItem: addedItem)
        case let .onAddSearchItemFailure(error):
            return onAddSearchItemFailure(state: state, error: error)
        case .onAddSearchResultPopupShown:
            return onAddSearchResultPopupShown(state: state)

        // Medication
        case .dosageDidChange(let newDosage):
            return medicationDosageDidChange(state: state, newDosage: newDosage)

        // Save
        case .onCreateLogPressed:
            return onCreateLogPressed(state: state)
        case let .onCreateLogSuccess(newLog):
            return onCreateLogSuccess(state: state, newLog: newLog)
        case let .onCreateLogFailure(error):
            return onCreateLogFailure(state: state, error: error)
        case .createErrorShown:
            return createErrorShown(state: state)
        }
    }

    private static func resetCreateLogState(state: AppState) -> AppState {
        var newState = state
        newState.createLog = CreateLogState()
        return newState
    }

    private static func logCategoryDidChange(state: AppState, newIndex: Int) -> AppState {
        var newState = state
        newState.createLog.selectedCategoryIndex = newIndex
        newState.createLog.resetSearch()
        return newState
    }

    private static func noteDidUpdate(state: AppState, newNotes: String) -> AppState {
        var newState = state
        newState.createLog.notes = newNotes
        return newState
    }

    private static func searchQueryDidChange(state: AppState) -> AppState {
        var newState = state
        newState.createLog.isSearching = true
        return newState
    }

    private static func searchDidComplete(state: AppState, results: [LogSearchable]) -> AppState {
        var newState = state
        newState.createLog.isSearching = false
        newState.createLog.searchResults = results
        return newState
    }

    private static func searchItemDidSelect(state: AppState, selectedIndex: Int) -> AppState {
        let selected = state.createLog.searchResults[selectedIndex]
        return searchItemDidSelect(state: state, selected: selected)
    }

    private static func onAddSearchItemPressed(state: AppState) -> AppState {
        var newState = state
        newState.createLog.isCreatingLogItem = true
        return newState
    }

    private static func onAddSearchItemSuccess(state: AppState, newItem: LogSearchable) -> AppState {
        // Select the new item
        var newState = searchItemDidSelect(state: state, selected: newItem)
        // Add to search results
        newState.createLog.searchResults.insert(newItem, at: 0)
        newState.createLog.createLogItemSuccess = true
        newState.createLog.isCreatingLogItem = false
        return newState
    }

    private static func onAddSearchItemFailure(state: AppState, error: Error) -> AppState {
        var newState = state
        newState.createLog.createLogItemError = error
        newState.createLog.isCreatingLogItem = false
        return newState
    }

    private static func onAddSearchResultPopupShown(state: AppState) -> AppState {
        var newState = state
        // Reset the success/error state
        newState.createLog.isCreatingLogItem = false
        newState.createLog.createLogItemError = nil
        newState.createLog.createLogItemSuccess = false
        return newState
    }

    private static func searchItemDidSelect(state: AppState, selected: LogSearchable) -> AppState {
        var newState = state
        switch state.createLog.selectedCategory {
        case .medication:
            guard let selectedMedication = selected as? Medication else {
                fatalError("Search result is not a medication but the selected category is medication")
            }
            newState.createLog.medication.selectedMedication = selectedMedication
        default:
            break
        }
        return newState
    }

    private static func medicationDosageDidChange(state: AppState, newDosage: String) -> AppState {
        var newState = state
        newState.createLog.medication.dosage = newDosage
        return newState
    }

    private static func onCreateLogPressed(state: AppState) -> AppState {
        var newState = state
        newState.createLog.isCreatingLog = true
        return newState
    }

    private static func onCreateLogSuccess(state: AppState, newLog: Loggable) -> AppState {
        var newState = state
        newState.createLog.isCreatingLog = false
        newState.createLog.createSuccess = true
        newState.homeScreen.recentLogs.insert(newLog, at: 0)
        return newState
    }

    private static func onCreateLogFailure(state: AppState, error: Error) -> AppState {
        var newState = state
        newState.createLog.isCreatingLog = false
        newState.createLog.createError = error
        return newState
    }

    private static func createErrorShown(state: AppState) -> AppState {
        var newState = state
        // Reset the error state
        newState.createLog.createError = nil
        return newState
    }

}