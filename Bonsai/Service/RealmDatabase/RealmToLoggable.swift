//
// Created by Frank Jia on 2020-02-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// Functions to transform a Realm data model to a loggable
extension RealmService {
    func getLoggable(from realmLoggable: RealmLoggable) -> Loggable? {
        guard let category = LogCategory.fromSerializedLogCategoryName(realmLoggable.categoryRawValue) else {
            AppLogging.warn("Could not parse Realm Loggable category \(realmLoggable.categoryRawValue)")
            return nil
        }
        // Get common fields
        let id = realmLoggable.id
        let title = realmLoggable.title
        let dateCreated = realmLoggable.dateCreated
        let notes = realmLoggable.notes
        switch category {
        case .medication:
            guard let realmMedicationLog = realmLoggable.medicationLog else {
                AppLogging.warn("Medication log property is nil")
                return nil
            }
            return MedicationLog(
                    id: id,
                    title: title,
                    dateCreated: dateCreated,
                    notes: notes,
                    medicationId: realmMedicationLog.medicationId,
                    dosage: realmMedicationLog.dosage
            )
        case .nutrition:
            guard let realmNutritionLog = realmLoggable.nutritionLog else {
                AppLogging.warn("Nutrition log property is nil")
                return nil
            }
            return NutritionLog(
                    id: id,
                    title: title,
                    dateCreated: dateCreated,
                    notes: notes,
                    nutritionItemId: realmNutritionLog.nutritionItemId,
                    amount: realmNutritionLog.amount
            )
        case .activity:
            guard let realmActivityLog = realmLoggable.activityLog else {
                AppLogging.warn("Activity log property is nil")
                return nil
            }
            return ActivityLog(
                    id: id,
                    title: title,
                    dateCreated: dateCreated,
                    notes: notes,
                    activityId: realmActivityLog.activityId,
                    duration: TimeInterval(realmActivityLog.durationRawValue)
            )
        case .symptom:
            guard let realmSymptomLog = realmLoggable.symptomLog else {
                AppLogging.warn("Symptom log property is nil")
                return nil
            }
            guard let severity = SymptomLog.Severity(rawValue: realmSymptomLog.severityRawValue) else {
                AppLogging.warn("Could not parse symptom severity")
                return nil
            }
            return SymptomLog(
                    id: id,
                    title: title,
                    dateCreated: dateCreated,
                    notes: notes,
                    symptomId: realmSymptomLog.symptomId,
                    severity: severity
            )
        case .mood:
            guard let realmMoodLog = realmLoggable.moodLog else {
                AppLogging.warn("Mood log property is nil")
                return nil
            }
            guard let moodRank = MoodRank(rawValue: realmMoodLog.moodRankRawValue) else {
                AppLogging.warn("Could not parse mood rank")
                return nil
            }
            return MoodLog(
                    id: id,
                    title: title,
                    dateCreated: dateCreated,
                    notes: notes,
                    moodRank: moodRank
            )
        case .note:
            return NoteLog(
                    id: id,
                    title: title,
                    dateCreated: dateCreated,
                    notes: notes
            )
        }
    }
}
