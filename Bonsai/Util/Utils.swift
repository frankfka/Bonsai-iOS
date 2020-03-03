//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    func isEmptyWithoutWhitespace() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension TimeInterval {
    static let hour: TimeInterval = TimeInterval(3600)
    static let day: TimeInterval = 24 * hour
    static let week: TimeInterval = 7 * day
}

struct AppUtils {

    // Filter a list of loggables into different loggable types
    static func splitLoggablesByType(logs: [Loggable]) -> LoggablesByType {
        var moodLogs: [MoodLog] = []
        var nutritionLogs: [NutritionLog] = []
        var symptomLogs: [SymptomLog] = []
        var medicationLogs: [MedicationLog] = []
        var activityLogs: [ActivityLog] = []
        var noteLogs: [NoteLog] = []
        var unparsedLogs: [Loggable] = []

        for log in logs {
            switch log.category {
            case .symptom:
                guard let symptomLog = log as? SymptomLog else {
                    fallthrough
                }
                symptomLogs.append(symptomLog)
            case .activity:
                guard let activityLog = log as? ActivityLog else {
                    fallthrough
                }
                activityLogs.append(activityLog)
            case .nutrition:
                guard let nutritionLog = log as? NutritionLog else {
                    fallthrough
                }
                nutritionLogs.append(nutritionLog)
            case .medication:
                guard let medicationLog = log as? MedicationLog else {
                    fallthrough
                }
                medicationLogs.append(medicationLog)
            case .mood:
                guard let moodLog = log as? MoodLog else {
                    fallthrough
                }
                moodLogs.append(moodLog)
            case .note:
                guard let noteLog = log as? NoteLog else {
                    fallthrough
                }
                noteLogs.append(noteLog)
            default:
                unparsedLogs.append(log)
            }
        }

        return LoggablesByType(
                moodLogs: moodLogs,
                nutritionLogs: nutritionLogs,
                symptomLogs: symptomLogs,
                medicationLogs: medicationLogs,
                activityLogs: activityLogs,
                noteLogs: noteLogs,
                unparsedLogs: unparsedLogs
        )
    }
}

struct LoggablesByType {
    let moodLogs: [MoodLog]
    let nutritionLogs: [NutritionLog]
    let symptomLogs: [SymptomLog]
    let medicationLogs: [MedicationLog]
    let activityLogs: [ActivityLog]
    let noteLogs: [NoteLog]
    let unparsedLogs: [Loggable]
}
