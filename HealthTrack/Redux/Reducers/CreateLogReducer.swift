//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogReducer {
    static func reduce(state: AppState, action: CreateLogAction) -> AppState {
        var newState = state
        switch action {
        case .screenDidShow:
            newState.createLog = CreateLogState()
        case .screenDidDismiss:
            newState.createLog = CreateLogState()
        case let .logCategoryDidChange(newIndex):
            newState = logCategoryDidChange(state: state, newIndex: newIndex)
        case let .noteDidUpdate(note):
            newState.createLog.notes = note
        case .searchQueryDidChange:
            newState.createLog.isSearching = true
        case .searchDidComplete(let results):
            newState.createLog.isSearching = false
            newState.createLog.searchResults = results
        case .searchItemDidSelect(let index):
            newState = searchItemDidSelect(state: state, selectedIndex: index)

        // Medication
        case .dosageDidChange(let newDosage):
            newState.createLog.medication.dosage = newDosage

        // Save
        case .onCreateLogPressed:
            newState.createLog.isCreating = true
        case .onCreateLogSuccess:
            newState.createLog.isCreating = false
            newState.createLog.createSuccess = true
        case let .onCreateLogFailure(error):
            newState.createLog.isCreating = false
            newState.createLog.createError = error
        case .createErrorShown:
            newState.createLog.createError = nil
        }
        return newState
    }

    private static func logCategoryDidChange(state: AppState, newIndex: Int) -> AppState {
        var newState = state
        newState.createLog.selectedCategoryIndex = newIndex
        newState.createLog.resetSearch()
        return newState
    }

    private static func searchItemDidSelect(state: AppState, selectedIndex: Int) -> AppState {
        var newState = state
        switch state.createLog.selectedCategory {
        case .medication:
            guard let selectedMedication = state.createLog.searchResults[selectedIndex] as? Medication else {
                fatalError("Search result is not a medication but the selected category is medication")
            }
            newState.createLog.medication.selectedMedication = selectedMedication
        default:
            break
        }
        return newState
    }

}