//
// Created by Frank Jia on 2019-12-15.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct SerializationConstants {

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

        // Symptoms
        struct Symptom {
            static let Collection = "symptoms"
            static let IdField = "symptomId"
        }

        // Activities
        struct Activity {
            static let Collection = "activities"
            static let IdField = "activityId"
        }

    }

    // Characteristics for user documents
    struct User {
        static let Collection = "users"
        static let IdField = "userId"
        static let DateCreatedField = "dateCreated"
        static let LinkedGoogleAccountField = "linkedGoogleAccount"

        struct FirebaseGoogleAccount {
            static let IdField = "googleId"
            static let NameField = "name"
            static let EmailField = "email"
        }
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

        // Logs - Symptoms
        struct Symptom {
            static let CategoryName = "symptom"
            static let SelectedSymptomIdField = "symptomId"
            static let SeverityField = "severity"
        }

        // Logs - Activity
        struct Activity {
            static let CategoryName = "activity"
            static let SelectedActivityIdField = "activityId"
            static let DurationField = "duration"
        }

        // Logs - Notes
        struct Note {
            static let CategoryName = "note"
        }
    }
}