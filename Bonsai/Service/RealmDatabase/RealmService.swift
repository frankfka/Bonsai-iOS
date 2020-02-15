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
            db = try Realm()
        } catch let error as NSError {
            throw ServiceError(message: "Could not create Realm database", wrappedError: error)
        }
    }

    func saveLog(log: Loggable) -> ServiceError? {
        guard let realmLog = getRealmLog(from: log) else {
            return ServiceError(message: "Could not create Realm log from loggable")
        }
        do {
            try self.db.write {
                self.db.add(realmLog)
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

    func deleteLog(with id: String) -> ServiceError? {
        // TODO
        // Note: need to also delete the category specific log entry
        return nil
    }

    func resetLocalStorage() -> ServiceError? {
        do {
            try self.db.write {
                self.db.deleteAll()
            }
        } catch let error as NSError {
            return ServiceError(message: "Error resetting local storage", wrappedError: error)
        }
        return nil
    }
}
