//
// Created by Frank Jia on 2020-03-20.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

extension Loggable {
    func encodeCommonFields() -> [String: Any] {
        return [
            SerializationConstants.Logs.IdField: self.id,
            SerializationConstants.Logs.TitleField: self.title,
            SerializationConstants.Logs.DateCreatedField: self.dateCreated,
            SerializationConstants.Logs.CategoryField: self.category.serializedLogCategoryName(),
            SerializationConstants.Logs.NotesField: self.notes
        ]
    }

    func encode() -> [String: Any] {
        var data = self.encodeCommonFields()
        switch self.category {
        case .mood:
            guard let moodLog = self as? MoodLog else {
                fatalError("Not a mood log but category was mood")
            }
            data[SerializationConstants.Logs.Mood.MoodRankField] = moodLog.moodRank.rawValue
        case .medication:
            guard let medicationLog = self as? MedicationLog else {
                fatalError("Not a medication log but category was medication")
            }
            data[SerializationConstants.Logs.Medication.SelectedMedicationIdField] = medicationLog.medicationId
            data[SerializationConstants.Logs.Medication.DosageField] = medicationLog.dosage
        case .nutrition:
            guard let nutritionLog = self as? NutritionLog else {
                fatalError("Not a nutrition log but category was nutrition")
            }
            data[SerializationConstants.Logs.Nutrition.SelectedNutritionIdField] = nutritionLog.nutritionItemId
            data[SerializationConstants.Logs.Nutrition.AmountField] = nutritionLog.amount
        case .activity:
            guard let activityLog = self as? ActivityLog else {
                fatalError("Not an activity log but category was activity")
            }
            data[SerializationConstants.Logs.Activity.SelectedActivityIdField] = activityLog.activityId
            data[SerializationConstants.Logs.Activity.DurationField] = abs(activityLog.duration.magnitude)
        case .symptom:
            guard let symptomLog = self as? SymptomLog else {
                fatalError("Not a symptom log but category was symptom")
            }
            data[SerializationConstants.Logs.Symptom.SelectedSymptomIdField] = symptomLog.symptomId
            data[SerializationConstants.Logs.Symptom.SeverityField] = symptomLog.severity.rawValue
        case .note:
            // No additional fields
            break
        }
        return data
    }
}

// Extension for log category lookup names
extension LogCategory {
    func firebaseLogSearchableCollectionName() -> String? {
        switch self {
        case .medication:
            return SerializationConstants.Searchable.Medication.Collection
        case .nutrition:
            return SerializationConstants.Searchable.Nutrition.Collection
        case .symptom:
            return SerializationConstants.Searchable.Symptom.Collection
        case .activity:
            return SerializationConstants.Searchable.Activity.Collection
        default:
            break
        }
        AppLogging.warn("Attempted to retrieve non searchable collection \(self.displayValue())")
        return nil
    }

    static func fromFirebaseCollectionName(_ name: String) -> LogCategory? {
        switch name {
        case SerializationConstants.Searchable.Medication.Collection:
            return .medication
        case SerializationConstants.Searchable.Nutrition.Collection:
            return .nutrition
        case SerializationConstants.Searchable.Activity.Collection:
            return .activity
        case SerializationConstants.Searchable.Symptom.Collection:
            return .symptom
        default:
            break
        }
        AppLogging.warn("Attempt to retrieve Firebase collection name for non-searchable category")
        return nil
    }
}
