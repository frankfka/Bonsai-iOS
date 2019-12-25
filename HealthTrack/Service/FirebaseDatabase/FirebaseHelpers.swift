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
            let id = data[FirebaseConstants.Searchable.MedicationIdField] as? String
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
        let dateCreated = (data[FirebaseConstants.User.DateCreatedField] as? Timestamp)?.dateValue()
        if let userId = userId, let dateCreated = dateCreated {
            return User(id: userId, dateCreated: dateCreated)
        }
        return nil
    }
}

extension Loggable {
    func encodeCommonFields() -> [String: Any] {
        return [
            FirebaseConstants.Logs.IdField: self.id,
            FirebaseConstants.Logs.DateCreatedField: self.dateCreated,
            FirebaseConstants.Logs.CategoryField: self.category.rawValue,
            FirebaseConstants.Logs.NotesField: self.notes
        ]
    }

    func encode() -> [String: Any] {
        let commonFieldsData = self.encodeCommonFields()
        var categoryFields: [String: Any] = [:]
        switch self.category {
        case .medication:
            guard let medicationLog = self as? MedicationLog else {
                fatalError("Not a medication log but category was medication")
            }
            categoryFields[FirebaseConstants.Logs.Medication.UserLogsMedicationIdField] = medicationLog.medicationId
            categoryFields[FirebaseConstants.Logs.Medication.DosageField] = medicationLog.dosage
        default:
            break
        }
        // Merge common + specific fields, keeping new field values if they conflict (they shouldn't)
        return commonFieldsData.merging(categoryFields, uniquingKeysWith: { (_, new) in new })
    }
}

extension LogCategory {
    func firebaseCollectionName() -> String {
        switch self {
        case .medication:
            return FirebaseConstants.Searchable.MedicationCollection
        default:
            return ""
        }
    }
}