//
// Created by Frank Jia on 2020-02-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {

    private let db: Realm

    // Limits as Realm returns everything, we wouldn't want to map all the objects
    private let logQueryLimit = 400 // Maximum logs to return at a given time
    private let logReminderLimit = 50 // Maximum reminders to return at a given time

    init() throws {
        Realm.Configuration.defaultConfiguration = RealmService.AppRealmConfiguration
        do {
            // This is only specified for the main thread, calls to this realm from any other thread will throw
            db = try Realm()
        } catch let error as NSError {
            throw ServiceError(message: "Could not create Realm database", wrappedError: error)
        }
    }

    // MARK: Logs
    func saveLogs(logs: [Loggable]) -> ServiceError? {
        let realmLogs = logs.compactMap {
            getRealmLog(from: $0)
        }
        if realmLogs.count != logs.count {
            return ServiceError(message: "Could not create one or more Realm logs from loggables")
        }
        return save(realmLogs)
    }

    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                 limit: Int?, startingAfterLog: Loggable?) -> [Loggable] {
        var realmLogs = self.db.objects(RealmLoggable.self)
        // Filter out templates used in log reminders
        realmLogs = realmLogs.filter("\(RealmLoggable.isTemplateKey) == FALSE")
        if let beginDate = beginDate {
            realmLogs = realmLogs.filter("\(RealmLoggable.dateCreatedKey) >= %@", beginDate)
        }
        if let endDate = endDate {
            realmLogs = realmLogs.filter("\(RealmLoggable.dateCreatedKey) <= %@", endDate)
        }
        // Sort by reverse chronological order
        realmLogs = realmLogs.sorted(byKeyPath: RealmLoggable.dateCreatedKey, ascending: false)
        // Enforce limit - Realm lazy-reads items
        var loggables: [Loggable] = []
        // Only return a set # of results, these are in reverse chronological order now
        var beginAddingLogs: Bool = startingAfterLog == nil
        let fetchLimit = limit ?? logQueryLimit
        for realmLog in realmLogs {
            // We have the correct #
            if loggables.count == fetchLimit {
                break
            }
            if beginAddingLogs {
                // Add logs as usual
                if let loggable = getLoggable(from: realmLog) {
                    loggables.append(loggable)
                } else {
                    AppLogging.warn("Could not get Loggable from Realm object \(realmLog.id) created on \(realmLog.dateCreated)")
                }
            } else if let startingAfterLog = startingAfterLog, realmLog.id == startingAfterLog.id {
                // Found the beginning loggable, start adding on next interation
                beginAddingLogs = true
            }
        }
        return loggables
    }

    func deleteLogs(with ids: [String]) -> ServiceError? {
        var toDelete: [Object] = []
        for id in ids {
            let objectsToDeleteForId = getRealmLoggablesToDelete(for: id)
            if objectsToDeleteForId.isEmpty {
                AppLogging.warn("Could not find Realm objects to delete")
            } else {
                toDelete.append(contentsOf: objectsToDeleteForId)
            }
        }
        return delete(toDelete)
    }

    // This returns the main loggable object, but also nested log objects
    private func getRealmLoggablesToDelete(for loggableId: String) -> [Object] {
        var objectsToDelete: [Object] = []
        guard let loggableToDelete = self.db.object(ofType: RealmLoggable.self, forPrimaryKey: loggableId) else {
            AppLogging.warn("Could not find loggable \(loggableId) to delete from Realm")
            return objectsToDelete
        }
        objectsToDelete.append(loggableToDelete)
        // Need to also delete the nested objects
        if let realmMoodLog = loggableToDelete.moodLog {
            objectsToDelete.append(realmMoodLog)
        } else if let realmMedicationLog = loggableToDelete.medicationLog {
            objectsToDelete.append(realmMedicationLog)
        } else if let realmNutritionLog = loggableToDelete.nutritionLog {
            objectsToDelete.append(realmNutritionLog)
        } else if let realmActivityLog = loggableToDelete.activityLog {
            objectsToDelete.append(realmActivityLog)
        } else if let realmSymptomLog = loggableToDelete.symptomLog {
            objectsToDelete.append(realmSymptomLog)
        }
        return objectsToDelete
    }

    // MARK: Log Reminders
    func getLogReminders() -> [LogReminder] {
        var realmLogReminders = self.db.objects(RealmLogReminder.self)
        // Sort by chronological order (earliest reminders first)
        realmLogReminders = realmLogReminders.sorted(byKeyPath: RealmLogReminder.reminderDateKey, ascending: true)
        // Enforce limit - Realm lazy-reads items
        var logReminders: [LogReminder] = []
        let endIndex = logReminderLimit <= realmLogReminders.endIndex ? logReminderLimit : realmLogReminders.endIndex
        for index in 0..<endIndex {
            if let logReminder = getLogReminder(from: realmLogReminders[index]) {
                logReminders.append(logReminder)
            } else {
                AppLogging.warn("Could not get log reminder from Realm Object")
            }
        }
        return logReminders
    }

    func saveLogReminder(_ logReminder: LogReminder) -> ServiceError? {
        guard let realmLogReminder = getRealmLogReminder(from: logReminder) else {
            return ServiceError(message: "Could not create Realm log reminder")
        }
        return save([realmLogReminder])
    }

    func deleteLogReminder(_ logReminder: LogReminder) -> ServiceError? {
        var objectsToDelete: [Object] = []
        guard let logReminderToDelete = self.db.object(ofType: RealmLogReminder.self, forPrimaryKey: logReminder.id) else {
            return ServiceError(message: "Could not find log reminder \(logReminder.id) to delete from Realm")
        }
        objectsToDelete.append(logReminderToDelete)
        // Get all loggables to delete that are associated with the reminder
        objectsToDelete.append(contentsOf: getRealmLoggablesToDelete(for: logReminder.templateLoggable.id))
        return delete(objectsToDelete)
    }

    func deleteAllObjects() -> ServiceError? {
        do {
            try self.db.write {
                self.db.deleteAll()
            }
        } catch let error as NSError {
            return ServiceError(message: "Error deleting all local objects", wrappedError: error)
        }
        return nil
    }

    // MARK: Helpers
    private func save(_ objects: [Object]) -> ServiceError? {
        do {
            try self.db.write {
                // Allow overwrites
                self.db.add(objects, update: .modified)
            }
        } catch let error as NSError {
            return ServiceError(message: "Error saving log", wrappedError: error)
        }
        return nil
    }

    private func delete(_ objects: [Object]) -> ServiceError? {
        do {
            try self.db.write {
                self.db.delete(objects)
            }
        } catch let error as NSError {
            return ServiceError(message: "Error deleting log from Realm", wrappedError: error)
        }
        return nil
    }

}
