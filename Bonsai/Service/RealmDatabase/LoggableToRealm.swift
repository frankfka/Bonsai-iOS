//
// Created by Frank Jia on 2020-02-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// Functions to transform a loggable into a Realm data model
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
        return realmNutritionLog
    }

    private func getRealmMedicationLog(from loggable: MedicationLog) -> RealmMedicationLog {
        let realmMedicationLog = RealmMedicationLog()
        return realmMedicationLog
    }

    private func getRealmMoodLog(from loggable: MoodLog) -> RealmMoodLog {
        let realmMoodLog = RealmMoodLog()
        return realmMoodLog
    }
}
