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
        switch parentCategory {
        case .medication:
            let id = data[FirebaseConstants.Searchable.Medication.IdField] as? String
            let name = data[FirebaseConstants.Searchable.ItemNameField] as? String
            let createdBy = data[FirebaseConstants.Searchable.CreatedByField] as? String
            if let name = name, let id = id, let createdBy = createdBy {
                return Medication(id: id, name: name, createdBy: createdBy)
            }
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
        case .medication:
            guard let medicationId = data[FirebaseConstants.Logs.Medication.IdField] as? String,
                  let dosage = data[FirebaseConstants.Logs.Medication.DosageField] as? String else {
                AppLogging.warn("Unable to decode medication log with data \(data)")
                return nil
            }
            return MedicationLog(
                    id: id,
                    title: title,
                    dateCreated: dateCreated,
                    notes: notes,
                    medicationId: medicationId,
                    dosage: dosage
            )
        case .note:
            return NoteLog(id: id, title: title, dateCreated: dateCreated, notes: notes)
        default:
            break
        }
        return nil
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
        case .medication:
            guard let medicationLog = self as? MedicationLog else {
                fatalError("Not a medication log but category was medication")
            }
            data[FirebaseConstants.Logs.Medication.IdField] = medicationLog.medicationId
            data[FirebaseConstants.Logs.Medication.DosageField] = medicationLog.dosage
        case .note:
            // No additional fields
            break
        default:
            break
        }
        return data
    }
}

extension LogCategory {
    func firebaseCollectionName() -> String {
        switch self {
        case .medication:
            return FirebaseConstants.Searchable.Medication.Collection
        default:
            return ""
        }
    }
    func firebaseLogCategoryName() -> String {
        switch self {
        case .medication:
            return FirebaseConstants.Logs.Medication.CategoryName
        default:
            return ""
        }
    }

    static func fromFirebaseCollectionName(_ name: String) -> LogCategory? {
        switch name {
        case FirebaseConstants.Searchable.Medication.Collection:
            return .medication
        default:
            break
        }
        return nil
    }
    static func fromFirebaseLogCategoryName(_ name: String) -> LogCategory? {
        switch name {
        case FirebaseConstants.Logs.Medication.CategoryName:
            return .medication
        default:
            break
        }
        return nil
    }

}
