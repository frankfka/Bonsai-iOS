//
// Created by Frank Jia on 2020-02-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {

    private let db: Realm

    private let logQueryLimit = 50 // Maximum logs to return at a given time

    init() throws {
        do {
            // This is only specified for the main thread, calls to this realm from any other thread will throw
            db = try Realm()
        } catch let error as NSError {
            throw ServiceError(message: "Could not create Realm database", wrappedError: error)
        }
    }

    func saveLogs(logs: [Loggable]) -> ServiceError? {
        let realmLogs = logs.compactMap { getRealmLog(from: $0) }
        if realmLogs.count != logs.count {
            return ServiceError(message: "Could not create one or more Realm logs from loggables")
        }
        return saveRealmLogs(logs: realmLogs)
    }

    private func saveRealmLogs(logs: [RealmLoggable]) -> ServiceError? {
        do {
            try self.db.write {
                // Allow overwrites
                self.db.add(logs, update: .modified)
            }
        } catch let error as NSError {
            return ServiceError(message: "Error saving log", wrappedError: error)
        }
        return nil
    }

    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                 limit: Int?) -> [Loggable] {
        var realmLogs = self.db.objects(RealmLoggable.self)
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
        let fetchLimit = limit ?? logQueryLimit
        let endIndex = fetchLimit <= realmLogs.endIndex ? fetchLimit : realmLogs.endIndex
        for index in 0 ..< endIndex {
            if let loggable = getLoggable(from: realmLogs[index]) {
                loggables.append(loggable)
            } else {
                AppLogging.warn("Could not get Loggable from Realm Object")
            }
        }
        return loggables
    }

    func deleteLogs(with ids: [String]) -> ServiceError? {
        do {
            try self.db.write {
                for id in ids {
                    let objectsToDelete = getRealmLoggablesToDelete(for: id)
                    if objectsToDelete.isEmpty {
                        AppLogging.warn("Could not find Realm objects to delete")
                    } else {
                        self.db.delete(objectsToDelete)
                    }
                }
            }
        } catch let error as NSError {
            return ServiceError(message: "Error deleting log from Realm", wrappedError: error)
        }
        return nil
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

}
