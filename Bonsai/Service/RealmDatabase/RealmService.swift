//
// Created by Frank Jia on 2020-02-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {

    private let db: Realm

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

    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?) -> [Loggable] {
        // TODO
        return []
    }

    func deleteLog(for user: User, with id: String) -> ServiceError? {
        // TODO
        return nil
    }
}
