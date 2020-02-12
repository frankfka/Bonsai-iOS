//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogState {

    struct MoodLogState {
        let allMoodRanks: [MoodRank] = MoodRank.allCases
        var selectedMoodRankIndex: Int? = nil
        var selectedMoods: [Mood] = []  // TODO: not implemented
    }
    struct MedicationLogState {
        var selectedMedication: Medication? = nil
        var dosage: String = ""
    }
    struct NutritionLogState {
        var selectedItem: NutritionItem? = nil
        var amount: String = ""
    }
    struct SymptomLogState {
        var selectedSymptom: Symptom? = nil
        var severity: SymptomLog.Severity = .none
    }
    struct ActivityLogState {
        var selectedActivity: Activity? = nil
        var duration: TimeInterval? = nil
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
    var date: Date = Date()
    var mood: MoodLogState = MoodLogState()
    var medication: MedicationLogState = MedicationLogState()
    var nutrition: NutritionLogState = NutritionLogState()
    var symptom: SymptomLogState = SymptomLogState()
    var activity: ActivityLogState = ActivityLogState()
}

// Helper functions
extension CreateLogState {
    func isFormValid() -> Bool {
        switch selectedCategory {
        case .note:
            return !notes.isEmptyWithoutWhitespace()
        case .mood:
            return mood.selectedMoodRankIndex != nil
        case .nutrition:
            return nutrition.selectedItem != nil && !nutrition.amount.isEmptyWithoutWhitespace()
        case .medication:
            return medication.selectedMedication != nil && !medication.dosage.isEmptyWithoutWhitespace()
        case .symptom:
            return symptom.selectedSymptom != nil
        case .activity:
            return activity.selectedActivity != nil && activity.duration != nil
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
