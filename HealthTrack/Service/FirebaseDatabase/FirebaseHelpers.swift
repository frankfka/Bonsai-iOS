//
// Created by Frank Jia on 2019-12-25.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

// Service extension to decode data - this is hacky but it's the only way that works with the protocol implementation
extension FirebaseService {
    func decode(data: [String: Any], parentCategory: LogCategory) -> LogSearchable? {
        // Common fields
        guard let name = data[FirebaseConstants.Searchable.ItemNameField] as? String,
              let createdBy = data[FirebaseConstants.Searchable.CreatedByField] as? String else {
            AppLogging.warn("Common log searchable fields not found")
            return nil
        }
        switch parentCategory {
        case .medication:
            guard let id = data[FirebaseConstants.Searchable.Medication.IdField] as? String else {
                AppLogging.warn("ID field not found")
                return nil
            }
            return Medication(id: id, name: name, createdBy: createdBy)
        case .nutrition:
            guard let id = data[FirebaseConstants.Searchable.Nutrition.IdField] as? String else {
                AppLogging.warn("ID field not found")
                return nil
            }
            return NutritionItem(id: id, name: name, createdBy: createdBy)
        case .symptom:
            guard let id = data[FirebaseConstants.Searchable.Symptom.IdField] as? String else {
                AppLogging.warn("ID field not found")
                return nil
            }
            return Symptom(id: id, name: name, createdBy: createdBy)
        case .activity:
            guard let id = data[FirebaseConstants.Searchable.Activity.IdField] as? String else {
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
        guard let logCategoryName = data[FirebaseConstants.Logs.CategoryField] as? String,
              let logCategory = LogCategory.fromFirebaseLogCategoryName(logCategoryName) else {
            AppLogging.warn("No log category found in log data: \(data)")
            return nil
        }
        // Get common fields
        guard let id = data[FirebaseConstants.Logs.IdField] as? String,
              let dateCreated = Date.fromFirebaseTimestamp(data[FirebaseConstants.Logs.DateCreatedField]),
              let title = data[FirebaseConstants.Logs.TitleField] as? String,
              let notes = data[FirebaseConstants.Logs.NotesField] as? String else {
            AppLogging.warn("Could not decode common fields in log data: \(data)")
            return nil
        }
        switch logCategory {
        case .mood:
            guard let moodRankEncoded = data[FirebaseConstants.Logs.Mood.MoodRankField] as? Int,
                  let moodRank = MoodRank(rawValue: moodRankEncoded) else {
                AppLogging.warn("Unable to decode mood rank with data \(data)")
                return nil
            }
            return MoodLog(id: id, title: title, dateCreated: dateCreated, notes: notes, moodRank: moodRank)
        case .nutrition:
            guard let nutritionItemId = data[FirebaseConstants.Logs.Nutrition.SelectedNutritionIdField] as? String,
                  let amount = data[FirebaseConstants.Logs.Nutrition.AmountField] as? String else {
                AppLogging.warn("Unable to decode nutrition log details with data \(data)")
                return nil
            }
            return NutritionLog(id: id, title: title, dateCreated: dateCreated, notes: notes,
                    nutritionItemId: nutritionItemId, amount: amount)
        case .medication:
            guard let medicationId = data[FirebaseConstants.Logs.Medication.SelectedMedicationIdField] as? String,
                  let dosage = data[FirebaseConstants.Logs.Medication.DosageField] as? String else {
                AppLogging.warn("Unable to decode medication log with data \(data)")
                return nil
            }
            return MedicationLog(id: id, title: title, dateCreated: dateCreated, notes: notes,
                    medicationId: medicationId, dosage: dosage)
        case .symptom:
            guard let symptomId = data[FirebaseConstants.Logs.Symptom.SelectedSymptomIdField] as? String,
                  let encodedSeverity = data[FirebaseConstants.Logs.Symptom.SeverityField] as? Int,
                  let severity = SymptomLog.Severity(rawValue: encodedSeverity) else {
                AppLogging.warn("Unable to decode symptom log with data \(data)")
                return nil
            }
            return SymptomLog(id: id, title: title, dateCreated: dateCreated, notes: notes,
                    symptomId: symptomId, severity: severity)
        case .activity:
            guard let activityId = data[FirebaseConstants.Logs.Activity.SelectedActivityIdField] as? String,
                  let intervalInSeconds = data[FirebaseConstants.Logs.Activity.DurationField] as? Double else {
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

// Model extensions for encode/decode
extension User {

    func encode() -> [String: Any] {
        return [
            FirebaseConstants.User.IdField: self.id,
            FirebaseConstants.User.DateCreatedField: self.dateCreated
        ]
    }

    static func decode(data: [String: Any]) -> User? {
        let userId = data[FirebaseConstants.User.IdField] as? String
        let dateCreated = Date.fromFirebaseTimestamp(data[FirebaseConstants.User.DateCreatedField])
        if let userId = userId, let dateCreated = dateCreated {
            return User(id: userId, dateCreated: dateCreated)
        }
        return nil
    }
}

// Convert timestamp to date
extension Date {
    static func fromFirebaseTimestamp(_ timestamp: Any?) -> Date? {
        return (timestamp as? Timestamp)?.dateValue()
    }
}

extension LogSearchable {
    func encodeCommonFields() -> [String: Any] {
        return [
            FirebaseConstants.Searchable.CreatedByField: self.createdBy,
            FirebaseConstants.Searchable.ItemNameField: self.name,
            FirebaseConstants.Searchable.SearchTermsField: getSearchTerms(),
        ]
    }

    private func getSearchTerms() -> [String] {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var terms: [String] = []
        for i in 0..<normalizedName.count {
            let endIndex = normalizedName.index(normalizedName.startIndex, offsetBy: i)
            terms.append(String(normalizedName.prefix(through: endIndex)))
        }
        return terms
    }

    func encode() -> [String: Any] {
        var data = encodeCommonFields()
        switch self.parentCategory {
        case .medication:
            data[FirebaseConstants.Searchable.Medication.IdField] = self.id
        case .nutrition:
            data[FirebaseConstants.Searchable.Nutrition.IdField] = self.id
        case .activity:
            data[FirebaseConstants.Searchable.Activity.IdField] = self.id
        case .symptom:
            data[FirebaseConstants.Searchable.Symptom.IdField] = self.id
        default:
            break
        }
        return data
    }
}

extension Loggable {
    func encodeCommonFields() -> [String: Any] {
        return [
            FirebaseConstants.Logs.IdField: self.id,
            FirebaseConstants.Logs.TitleField: self.title,
            FirebaseConstants.Logs.DateCreatedField: self.dateCreated,
            FirebaseConstants.Logs.CategoryField: self.category.firebaseLogCategoryName(),
            FirebaseConstants.Logs.NotesField: self.notes
        ]
    }

    func encode() -> [String: Any] {
        var data = self.encodeCommonFields()
        switch self.category {
        case .mood:
            guard let moodLog = self as? MoodLog else {
                fatalError("Not a mood log but category was mood")
            }
            data[FirebaseConstants.Logs.Mood.MoodRankField] = moodLog.moodRank.rawValue
        case .medication:
            guard let medicationLog = self as? MedicationLog else {
                fatalError("Not a medication log but category was medication")
            }
            data[FirebaseConstants.Logs.Medication.SelectedMedicationIdField] = medicationLog.medicationId
            data[FirebaseConstants.Logs.Medication.DosageField] = medicationLog.dosage
        case .nutrition:
            guard let nutritionLog = self as? NutritionLog else {
                fatalError("Not a nutrition log but category was nutrition")
            }
            data[FirebaseConstants.Logs.Nutrition.SelectedNutritionIdField] = nutritionLog.nutritionItemId
            data[FirebaseConstants.Logs.Nutrition.AmountField] = nutritionLog.amount
        case .activity:
            guard let activityLog = self as? ActivityLog else {
                fatalError("Not an activity log but category was activity")
            }
            data[FirebaseConstants.Logs.Activity.SelectedActivityIdField] = activityLog.activityId
            data[FirebaseConstants.Logs.Activity.DurationField] = abs(activityLog.duration.magnitude)
        case .symptom:
            guard let symptomLog = self as? SymptomLog else {
                fatalError("Not a symptom log but category was symptom")
            }
            data[FirebaseConstants.Logs.Symptom.SelectedSymptomIdField] = symptomLog.symptomId
            data[FirebaseConstants.Logs.Symptom.SeverityField] = symptomLog.severity.rawValue
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
            return FirebaseConstants.Searchable.Medication.Collection
        case .nutrition:
            return FirebaseConstants.Searchable.Nutrition.Collection
        case .symptom:
            return FirebaseConstants.Searchable.Symptom.Collection
        case .activity:
            return FirebaseConstants.Searchable.Activity.Collection
        default:
            break
        }
        AppLogging.warn("Attempted to retrieve non searchable collection \(self.displayValue())")
        return nil
    }
    func firebaseLogCategoryName() -> String {
        switch self {
        case .mood:
            return FirebaseConstants.Logs.Mood.CategoryName
        case .medication:
            return FirebaseConstants.Logs.Medication.CategoryName
        case .nutrition:
            return FirebaseConstants.Logs.Nutrition.CategoryName
        case .activity:
            return FirebaseConstants.Logs.Activity.CategoryName
        case .symptom:
            return FirebaseConstants.Logs.Symptom.CategoryName
        case .note:
            return FirebaseConstants.Logs.Note.CategoryName
        }
    }

    static func fromFirebaseCollectionName(_ name: String) -> LogCategory? {
        switch name {
        case FirebaseConstants.Searchable.Medication.Collection:
            return .medication
        case FirebaseConstants.Searchable.Nutrition.Collection:
            return .nutrition
        case FirebaseConstants.Searchable.Activity.Collection:
            return .activity
        case FirebaseConstants.Searchable.Symptom.Collection:
            return .symptom
        default:
            break
        }
        AppLogging.warn("Attempt to retrieve Firebase collection name for non-searchable category")
        return nil
    }
    static func fromFirebaseLogCategoryName(_ name: String) -> LogCategory? {
        switch name {
        case FirebaseConstants.Logs.Medication.CategoryName:
            return .medication
        case FirebaseConstants.Logs.Mood.CategoryName:
            return .mood
        case FirebaseConstants.Logs.Nutrition.CategoryName:
            return .nutrition
        case FirebaseConstants.Logs.Activity.CategoryName:
            return .activity
        case FirebaseConstants.Logs.Symptom.CategoryName:
            return .symptom
        case FirebaseConstants.Logs.Note.CategoryName:
            return .note
        default:
            break
        }
        AppLogging.warn("Invalid firebase log category \(name)")
        return nil
    }
}
