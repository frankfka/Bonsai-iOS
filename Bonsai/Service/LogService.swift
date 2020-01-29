//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Combine

protocol LogService {
    // CRUD on logs
    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?) -> ServicePublisher<[Loggable]>
    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void>
    func deleteLog(with id: String, for user: User) -> ServicePublisher<Void>
    // CRUD on log items (medications, nutrition, etc.)
    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable>
    func searchLogSearchables(with query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]>
    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void>
}

class LogServiceImpl: LogService {
    private let db: DatabaseService
    private let cache: CacheService

    init(db: DatabaseService, cache: CacheService) {
        self.db = db
        self.cache = cache
    }

    func getLogs(for user: User, in category: LogCategory? = nil, since beginDate: Date?, toAndIncluding endDate: Date?) -> ServicePublisher<[Loggable]> {
        return self.db.getLog(for: user, in: category, since: beginDate, toAndIncluding: endDate)
    }

    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void> {
        return self.db.saveLogSearchable(logItem: logItem, for: user)
    }

    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void> {
        return self.db.saveLog(log: log, for: user)
    }


    func deleteLog(with id: String, for user: User) -> ServicePublisher<Void> {
        return self.db.deleteLog(for: user, with: id)
    }

    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable> {
        if let cached = self.cache.getLogSearchable(with: id, in: category) {
            AppLogging.debug("Returning cached log searchable \(id)")
            return AnyPublisher(Just(cached).setFailureType(to: ServiceError.self))
        }
        return self.db.getLogSearchable(with: id, in: category).map { result -> LogSearchable in
            self.cache.saveLogSearchable(result)
            return result
        }.eraseToAnyPublisher()
    }

    func searchLogSearchables(with query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]> {
        return self.db.searchLogSearchables(query: query, by: user, in: category)
    }

}
