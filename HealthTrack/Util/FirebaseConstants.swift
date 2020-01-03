//
// Created by Frank Jia on 2019-12-15.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct FirebaseConstants {

    // Characteristics of searchable items (ex. medications, moods, etc.)
    struct Searchable {
        // Generic
        static let ItemNameField = "name"
        static let SearchTermsField = "searchTerms"
        static let CreatedByField = "createdBy"
        static let CreatedByMaster = "master"

        // Medication
        struct Medication {
            static let Collection = "medications"
            static let IdField = "medicationId"
        }

        // Nutrition
        struct Nutrition {
            static let Collection = "nutrition"
            static let IdField = "nutritionId"
        }
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
        static let TitleField = "title"
        static let DateCreatedField = "dateCreated"
        static let NotesField = "notes"

        // Logs - Medication
        struct Medication {
            static let CategoryName = "medication"
            static let SelectedMedicationIdField = "medicationId"
            static let DosageField = "dosage"
        }

        // Logs - Mood
        struct Mood {
            static let CategoryName = "mood"
            static let MoodRankField = "moodRank"
        }

        // Logs - Nutrition
        struct Nutrition {
            static let CategoryName = "nutrition"
            static let SelectedNutritionIdField = "nutritionId"
            static let AmountField = "amount"
        }

        // Logs - Notes
        struct Note {
            static let CategoryName = "note"
        }
    }
}