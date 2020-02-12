//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct CreateLogReducer {
    static func reduce(state: AppState, action: CreateLogAction) -> AppState {
        switch action {
        case .screenDidShow:
            return state
        case .screenDidDismiss:
            return resetCreateLogState(state: state)
        case let .logCategoryDidChange(newIndex):
            return logCategoryDidChange(state: state, newIndex: newIndex)
        case let .noteDidUpdate(notes):
            return noteDidUpdate(state: state, newNotes: notes)
        case let .dateDidChange(newDate):
            return dateDidChange(state: state, newDate: newDate)

        case let .initFromPreviousLog(loggable):
            return initFromPreviousLog(state: state, loggable: loggable)

        // Search
        case .searchQueryDidChange:
            return searchQueryDidChange(state: state)
        case .searchDidComplete(let results):
            return searchDidComplete(state: state, results: results)
        case .searchItemDidSelect(let index):
            return searchItemDidSelect(state: state, selectedIndex: index)
        case .onSearchViewDismiss:
            return onSearchViewDismiss(state: state)
        case .onAddSearchItemPressed:
            return onAddSearchItemPressed(state: state)
        case let .onAddSearchItemSuccess(addedItem):
            return onAddSearchItemSuccess(state: state, newItem: addedItem)
        case let .onAddSearchItemFailure(error):
            return onAddSearchItemFailure(state: state, error: error)
        case .onAddSearchResultPopupShown:
            return onAddSearchResultPopupShown(state: state)

        // Mood
        case .moodRankSelected(let selectedIndex):
            return moodRankSelected(state: state, selectedIndex: selectedIndex)

        // Medication
        case .medicationDosageDidChange(let newDosage):
            return medicationDosageDidChange(state: state, newDosage: newDosage)

        // Nutrition
        case .nutritionAmountDidChange(let newAmount):
            return nutritionAmountDidChange(state: state, newAmount: newAmount)

        // Symptom
        case .symptomSeverityDidChange(let encodedValue):
            return symptomSeverityDidChange(state: state, encodedValue: encodedValue)

        // Activity
        case .activityDurationDidChange(let newDuration):
            return activityDurationDidChange(state: state, newDuration: newDuration)

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

    // MARK: General
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

    private static func dateDidChange(state: AppState, newDate: Date) -> AppState {
        var newState = state
        newState.createLog.date = newDate
        return newState
    }

    // MARK: Init from previous
    private static func initFromPreviousLog(state: AppState, loggable: Loggable) -> AppState {
        var newState = state
        var newCreateLogState = CreateLogState()
        guard let loggableCategoryIndex = newCreateLogState.allCategories.firstIndex(of: loggable.category) else {
            AppLogging.warn("Category of loggable not found in state")
            return newState
        }
        newCreateLogState.selectedCategoryIndex = loggableCategoryIndex
        newCreateLogState.notes = loggable.notes
        switch loggable.category {
        case .symptom:
            guard let symptomLog = loggable as? SymptomLog else {
                AppLogging.warn("Could not cast loggable as symptom log")
                return newState
            }
            newCreateLogState.symptom.selectedSymptom = symptomLog.selectedSymptom
            newCreateLogState.symptom.severity = symptomLog.severity
        case .medication:
            guard let medicationLog = loggable as? MedicationLog else {
                AppLogging.warn("Could not cast loggable as medication log")
                return newState
            }
            newCreateLogState.medication.selectedMedication = medicationLog.selectedMedication
            newCreateLogState.medication.dosage = medicationLog.dosage
        case .activity:
            guard let activityLog = loggable as? ActivityLog else {
                AppLogging.warn("Could not cast loggable as activity log")
                return newState
            }
            newCreateLogState.activity.selectedActivity = activityLog.selectedActivity
            newCreateLogState.activity.duration = activityLog.duration
        case .nutrition:
            guard let nutritionLog = loggable as? NutritionLog else {
                AppLogging.warn("Could not cast loggable as nutrition log")
                return newState
            }
            newCreateLogState.nutrition.selectedItem = nutritionLog.selectedNutritionItem
            newCreateLogState.nutrition.amount = nutritionLog.amount
        case .mood:
            guard let moodLog = loggable as? MoodLog else {
                AppLogging.warn("Could not cast loggable as mood log")
                return newState
            }
            guard let moodRankIndex = newCreateLogState.mood.allMoodRanks.firstIndex(of: moodLog.moodRank) else {
                AppLogging.warn("Category of loggable not found in state")
                return newState
            }
            newCreateLogState.mood.selectedMoodRankIndex = moodRankIndex
        case .note:
            guard let noteLog = loggable as? NoteLog else {
                AppLogging.warn("Could not cast loggable as note log")
                return newState
            }
            newCreateLogState.notes = noteLog.notes
        }

        newState.createLog = newCreateLogState
        return newState
    }

    // MARK: Search
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

    private static func onSearchViewDismiss(state: AppState) -> AppState {
        var newState = state
        newState.createLog.searchResults = []
        newState.createLog.isSearching = false
        return newState
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
        AppLogging.error("Failure Action: \(error)")
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
        case .nutrition:
            guard let selectedNutrition = selected as? NutritionItem else {
                fatalError("Search result is not a nutrition item but the selected category is nutrition")
            }
            newState.createLog.nutrition.selectedItem = selectedNutrition
        case .activity:
            guard let selectedActivity = selected as? Activity else {
                fatalError("Search result is not an activity but the selected category is activity")
            }
            newState.createLog.activity.selectedActivity = selectedActivity
        case .symptom:
            guard let selectedSymptom = selected as? Symptom else {
                fatalError("Search result is not a symptom but the selected category is symptom")
            }
            newState.createLog.symptom.selectedSymptom = selectedSymptom
        default:
            break
        }
        return newState
    }

    // MARK: Mood
    private static func moodRankSelected(state: AppState, selectedIndex: Int) -> AppState {
        var newState = state
        if newState.createLog.mood.selectedMoodRankIndex == selectedIndex {
            // Tapping on already selected item - deselect
            newState.createLog.mood.selectedMoodRankIndex = nil
        } else {
            newState.createLog.mood.selectedMoodRankIndex = selectedIndex
        }
        return newState
    }

    // MARK: Medication
    private static func medicationDosageDidChange(state: AppState, newDosage: String) -> AppState {
        var newState = state
        newState.createLog.medication.dosage = newDosage
        return newState
    }

    // MARK: Nutrition
    private static func nutritionAmountDidChange(state: AppState, newAmount: String) -> AppState {
        var newState = state
        newState.createLog.nutrition.amount = newAmount
        return newState
    }

    // MARK: Symptom
    private static func symptomSeverityDidChange(state: AppState, encodedValue: Double) -> AppState {
        if let newSeverity = SymptomLog.Severity(rawValue: encodedValue) {
            var newState = state
            newState.createLog.symptom.severity = newSeverity
            return newState
        } else {
            AppLogging.warn("Could not decode new severity value \(encodedValue)")
            return state
        }
    }

    // MARK: Activity
    private static func activityDurationDidChange(state: AppState, newDuration: TimeInterval) -> AppState {
        var newState = state
        newState.createLog.activity.duration = newDuration
        return newState
    }

    // MARK: Create
    private static func onCreateLogPressed(state: AppState) -> AppState {
        var newState = state
        newState.createLog.isCreatingLog = true
        return newState
    }

    private static func onCreateLogSuccess(state: AppState, newLog: Loggable) -> AppState {
        var newState = state
        newState.createLog.isCreatingLog = false
        newState.createLog.createSuccess = true
        GlobalLogReducerUtil.add(state: &newState, newLog: newLog)
        return newState
    }

    private static func onCreateLogFailure(state: AppState, error: Error) -> AppState {
        AppLogging.error("Failure Action: \(error)")
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
