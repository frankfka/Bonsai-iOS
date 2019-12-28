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
            FirebaseConstants.Logs.DateCreatedField: self.dateCreated,
            FirebaseConstants.Logs.CategoryField: self.category.rawValue,
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
            data[FirebaseConstants.Logs.Medication.UserLogsMedicationIdField] = medicationLog.medicationId
            data[FirebaseConstants.Logs.Medication.DosageField] = medicationLog.dosage
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
}