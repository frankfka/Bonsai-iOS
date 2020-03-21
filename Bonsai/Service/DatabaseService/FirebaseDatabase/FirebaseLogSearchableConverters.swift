//
// Created by Frank Jia on 2020-03-20.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

extension LogSearchable {
    func encodeCommonFields() -> [String: Any] {
        return [
            SerializationConstants.Searchable.CreatedByField: self.createdBy,
            SerializationConstants.Searchable.ItemNameField: self.name,
            SerializationConstants.Searchable.SearchTermsField: getSearchTerms(),
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
            data[SerializationConstants.Searchable.Medication.IdField] = self.id
        case .nutrition:
            data[SerializationConstants.Searchable.Nutrition.IdField] = self.id
        case .activity:
            data[SerializationConstants.Searchable.Activity.IdField] = self.id
        case .symptom:
            data[SerializationConstants.Searchable.Symptom.IdField] = self.id
        default:
            break
        }
        return data
    }
}