//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogState {
    let allCategories: [LogCategory] = LogCategory.allCases
    var selectedCategoryIndex: Int = 0
    var selectedCategory: LogCategory {
        return allCategories[selectedCategoryIndex]
    }
    var notes: String = ""

    var searchQuery: String = ""
    var isSearching: Bool = false
    var searchResults: [LogSearchable] = []

    // Category specific
    var mood: MoodLogState = MoodLogState()
    var medication: MedicationLogState = MedicationLogState()

    // On submit states
    var loading: Bool = false
    var error: Error? = nil
    var success: Bool = false

    struct MoodLogState {
        var selectedMoodIds: [String] = []
    }

    struct MedicationLogState {
        var selectedMedication: Medication? = nil
        var dosage: String = ""
    }

    mutating func resetSearch() {
        self.searchQuery = ""
        self.searchResults = []
        self.isSearching = false
    }

}