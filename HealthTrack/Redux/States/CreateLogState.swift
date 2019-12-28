//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogState {

    struct MoodLogState {
        var selectedMoodIds: [String] = []
    }
    struct MedicationLogState {
        var selectedMedication: Medication? = nil
        var dosage: String = ""
    }

    let allCategories: [LogCategory] = LogCategory.allCases
    var selectedCategoryIndex: Int = 0
    var selectedCategory: LogCategory {
        return allCategories[selectedCategoryIndex]
    }

    // Search states
    var isSearching: Bool = false
    var searchResults: [LogSearchable] = []
    var isCreatingLogItem: Bool = false
    var createLogItemError: Error? = nil
    var createLogItemSuccess: Bool = false

    // On submit states
    var isCreatingLog: Bool = false
    var createError: Error? = nil
    var createSuccess: Bool = false

    // Category-specific states
    var isValidated: Bool {
        // Indicates whether all required fields are filled out
        isFormValid()
    }
    var notes: String = ""
    var mood: MoodLogState = MoodLogState()
    var medication: MedicationLogState = MedicationLogState()
}

// Helper functions
extension CreateLogState {
    func isFormValid() -> Bool {
        switch selectedCategory {
        case .note:
            return !notes.isEmptyWithoutWhitespace()
        case .medication:
            return medication.selectedMedication != nil && !medication.dosage.isEmptyWithoutWhitespace()
        default:
            return false
        }
    }
}

// Helper functions for modifying state
extension CreateLogState {
    mutating func resetSearch() {
        self.searchResults = []
        self.isSearching = false
    }
}