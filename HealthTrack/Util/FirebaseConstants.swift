//
// Created by Frank Jia on 2019-12-15.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct FirebaseConstants {

    // TODO: Sub-structs

    // Characteristics of searchable items (ex. medications, moods, etc.)
    struct Searchable {
        // Generic
        static let ItemNameField = "name"
        static let SearchTermsField = "searchTerms"
        // Medication
        static let MedicationCollection = "medications"
        static let MedicationIdField = "medicationId"
    }

    // Characteristics for user documents
    struct User {
        static let Collection = "users"
        static let IdField = "userId"
        static let DateCreatedField = "dateCreated"
    }

    struct Logs {
        // Logs
        static let Collection = "logs"
        static let CategoryField = "category"
        static let IdField = "logId"
        static let DateCreatedField = "dateCreated"
        static let NotesField = "notes"

        // Logs - Medication
        struct Medication {
            static let UserLogsMedicationIdField = "medicationId"
            static let DosageField = "dosage"
        }
    }
}