//
// Created by Frank Jia on 2020-02-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// MARK: Loggable to Realm
extension RealmService {
    func getRealmLog(from loggable: Loggable) -> RealmLoggable? {
        let newRealmLoggable = RealmLoggable()
        // Initialize common fields
        newRealmLoggable.id = loggable.id
        newRealmLoggable.title = loggable.title
        newRealmLoggable.dateCreated = loggable.dateCreated
        newRealmLoggable.categoryRawValue = loggable.category.serializedLogCategoryName()

        // Add category specific information
        switch loggable.category {
        case .symptom:
            guard let symptomLog = loggable as? SymptomLog else {
                AppLogging.warn("Category and Log type mismatch, could not create RealmLog")
                return nil
            }
            newRealmLoggable.symptomLog = getRealmSymptomLog(from: symptomLog)
            return newRealmLoggable
        case .activity:
            guard let activityLog = loggable as? ActivityLog else  {
                AppLogging.warn("Category and Log type mismatch, could not create RealmLog")
                return nil
            }
            newRealmLoggable.activityLog = getRealmActivityLog(from: activityLog)
            return newRealmLoggable
        case .nutrition:
            guard let nutritionLog = loggable as? NutritionLog else  {
                AppLogging.warn("Category and Log type mismatch, could not create RealmLog")
                return nil
            }
            newRealmLoggable.nutritionLog = getRealmNutritionLog(from: nutritionLog)
            return newRealmLoggable
        case .medication:
            guard let medicationLog = loggable as? MedicationLog else  {
                AppLogging.warn("Category and Log type mismatch, could not create RealmLog")
                return nil
            }
            newRealmLoggable.medicationLog = getRealmMedicationLog(from: medicationLog)
            return newRealmLoggable
        case .mood:
            guard let moodLog = loggable as? MoodLog else  {
                AppLogging.warn("Category and Log type mismatch, could not create RealmLog")
                return nil
            }
            newRealmLoggable.moodLog = getRealmMoodLog(from: moodLog)
            return newRealmLoggable
        case .note:
            return newRealmLoggable
        }
    }

    private func getRealmSymptomLog(from loggable: SymptomLog) -> RealmSymptomLog {
        let realmSymptomLog = RealmSymptomLog()
        realmSymptomLog.id = loggable.id
        realmSymptomLog.symptomId = loggable.symptomId
        realmSymptomLog.severityRawValue = loggable.severity.rawValue
        return realmSymptomLog
    }

    private func getRealmActivityLog(from loggable: ActivityLog) -> RealmActivityLog {
        let realmActivityLog = RealmActivityLog()
        realmActivityLog.id = loggable.id
        realmActivityLog.activityId = loggable.activityId
        realmActivityLog.durationRawValue = loggable.duration.magnitude
        return realmActivityLog
    }

    private func getRealmNutritionLog(from loggable: NutritionLog) -> RealmNutritionLog {
        let realmNutritionLog = RealmNutritionLog()
        realmNutritionLog.id = loggable.id
        realmNutritionLog.amount = loggable.amount
        realmNutritionLog.nutritionItemId = loggable.nutritionItemId
        return realmNutritionLog
    }

    private func getRealmMedicationLog(from loggable: MedicationLog) -> RealmMedicationLog {
        let realmMedicationLog = RealmMedicationLog()
        realmMedicationLog.id = loggable.id
        realmMedicationLog.dosage = loggable.dosage
        realmMedicationLog.medicationId = loggable.medicationId
        return realmMedicationLog
    }

    private func getRealmMoodLog(from loggable: MoodLog) -> RealmMoodLog {
        let realmMoodLog = RealmMoodLog()
        realmMoodLog.id = loggable.id
        realmMoodLog.moodRankRawValue = loggable.moodRank.rawValue
        return realmMoodLog
    }
}


// MARK: Realm to Loggable
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