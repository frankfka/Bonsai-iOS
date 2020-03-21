//
// Created by Frank Jia on 2019-12-25.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

// Service extension to decode data - this is hacky but it's the only way that works with the protocol implementation
extension FirebaseFirestoreService {
    func decode(data: [String: Any], parentCategory: LogCategory) -> LogSearchable? {
        // Common fields
        guard let name = data[SerializationConstants.Searchable.ItemNameField] as? String,
              let createdBy = data[SerializationConstants.Searchable.CreatedByField] as? String else {
            AppLogging.warn("Common log searchable fields not found")
            return nil
        }
        switch parentCategory {
        case .medication:
            guard let id = data[SerializationConstants.Searchable.Medication.IdField] as? String else {
                AppLogging.warn("ID field not found")
                return nil
            }
            return Medication(id: id, name: name, createdBy: createdBy)
        case .nutrition:
            guard let id = data[SerializationConstants.Searchable.Nutrition.IdField] as? String else {
                AppLogging.warn("ID field not found")
                return nil
            }
            return NutritionItem(id: id, name: name, createdBy: createdBy)
        case .symptom:
            guard let id = data[SerializationConstants.Searchable.Symptom.IdField] as? String else {
                AppLogging.warn("ID field not found")
                return nil
            }
            return Symptom(id: id, name: name, createdBy: createdBy)
        case .activity:
            guard let id = data[SerializationConstants.Searchable.Activity.IdField] as? String else {
                AppLogging.warn("ID field not found")
                return nil
            }
            return Activity(id: id, name: name, createdBy: createdBy)
        default:
            break
        }
        return nil
    }

    func decode(data: [String: Any]) -> Loggable? {
        // Get Category
        guard let logCategoryName = data[SerializationConstants.Logs.CategoryField] as? String,
              let logCategory = LogCategory.fromSerializedLogCategoryName(logCategoryName) else {
            AppLogging.warn("No log category found in log data: \(data)")
            return nil
        }
        // Get common fields
        guard let id = data[SerializationConstants.Logs.IdField] as? String,
              let dateCreated = Date.fromFirebaseTimestamp(data[SerializationConstants.Logs.DateCreatedField]),
              let title = data[SerializationConstants.Logs.TitleField] as? String,
              let notes = data[SerializationConstants.Logs.NotesField] as? String else {
            AppLogging.warn("Could not decode common fields in log data: \(data)")
            return nil
        }
        switch logCategory {
        case .mood:
            guard let moodRankEncoded = data[SerializationConstants.Logs.Mood.MoodRankField] as? Int,
                  let moodRank = MoodRank(rawValue: moodRankEncoded) else {
                AppLogging.warn("Unable to decode mood rank with data \(data)")
                return nil
            }
            return MoodLog(id: id, title: title, dateCreated: dateCreated, notes: notes, moodRank: moodRank)
        case .nutrition:
            guard let nutritionItemId = data[SerializationConstants.Logs.Nutrition.SelectedNutritionIdField] as? String,
                  let amount = data[SerializationConstants.Logs.Nutrition.AmountField] as? String else {
                AppLogging.warn("Unable to decode nutrition log details with data \(data)")
                return nil
            }
            return NutritionLog(id: id, title: title, dateCreated: dateCreated, notes: notes,
                    nutritionItemId: nutritionItemId, amount: amount)
        case .medication:
            guard let medicationId = data[SerializationConstants.Logs.Medication.SelectedMedicationIdField] as? String,
                  let dosage = data[SerializationConstants.Logs.Medication.DosageField] as? String else {
                AppLogging.warn("Unable to decode medication log with data \(data)")
                return nil
            }
            return MedicationLog(id: id, title: title, dateCreated: dateCreated, notes: notes,
                    medicationId: medicationId, dosage: dosage)
        case .symptom:
            guard let symptomId = data[SerializationConstants.Logs.Symptom.SelectedSymptomIdField] as? String,
                  let encodedSeverity = data[SerializationConstants.Logs.Symptom.SeverityField] as? Double,
                  let severity = SymptomLog.Severity(rawValue: encodedSeverity) else {
                AppLogging.warn("Unable to decode symptom log with data \(data)")
                return nil
            }
            return SymptomLog(id: id, title: title, dateCreated: dateCreated, notes: notes,
                    symptomId: symptomId, severity: severity)
        case .activity:
            guard let activityId = data[SerializationConstants.Logs.Activity.SelectedActivityIdField] as? String,
                  let intervalInSeconds = data[SerializationConstants.Logs.Activity.DurationField] as? Double else {
                AppLogging.warn("Unable to decode activity log with data \(data)")
                return nil
            }
            return ActivityLog(id: id, title: title, dateCreated: dateCreated, notes: notes,
                    activityId: activityId, duration: TimeInterval(intervalInSeconds))
        case .note:
            return NoteLog(id: id, title: title, dateCreated: dateCreated, notes: notes)
        }
    }
}

// Convert timestamp to date
extension Date {
    static func fromFirebaseTimestamp(_ timestamp: Any?) -> Date? {
        return (timestamp as? Timestamp)?.dateValue()
    }
}