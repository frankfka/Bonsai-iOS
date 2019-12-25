//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogReducer {
    static func reduce(state: inout AppState, action: CreateLogAction) {
        switch action {
        case .screenDidShow:
            state.createLog = CreateLogState()
        case .screenDidDismiss:
            state.createLog = CreateLogState()
        case let .logCategoryDidChange(newIndex):
            logCategoryDidChange(state: &state, newIndex: newIndex)
        case let .noteDidUpdate(note):
            state.createLog.notes = note
        case .save:
            print("save")
        case .searchQueryDidChange(let query):
            state.createLog.searchQuery = query
            state.createLog.isSearching = true
        case .searchDidComplete(let results):
            state.createLog.isSearching = false
            state.createLog.searchResults = results
        case .searchItemDidSelect(let index):
            searchItemDidSelect(state: &state, selectedIndex: index)

        // Medication
        case .dosageDidChange(let newDosage):
            state.createLog.medication.dosage = newDosage
        }
    }

    private static func logCategoryDidChange(state: inout AppState, newIndex: Int) {
        state.createLog.selectedCategoryIndex = newIndex
        state.createLog.resetSearch()
    }

    private static func searchItemDidSelect(state: inout AppState, selectedIndex: Int) {
        switch state.createLog.selectedCategory {
        case .medication:
            guard let selectedMedication = state.createLog.searchResults[selectedIndex] as? Medication else {
                fatalError("Search result is not a medication but the selected category is medication")
            }
            state.createLog.medication.selectedMedication = selectedMedication
        default:
            break
        }
    }

}