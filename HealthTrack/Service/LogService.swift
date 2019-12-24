//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Combine

protocol LogService {
    func save(log: Loggable, for user: User) -> ServicePublisher<Void>
    func delete(id: String)
    func search(with query: String, by user: User) -> ServicePublisher<[Medication]>
}

class LogServiceImpl: LogService {
    private let db: DatabaseService

    init(db: DatabaseService) {
        self.db = db
    }

    func save(log: Loggable, for user: User) -> ServicePublisher<Void> {
        return self.db.save(log: log, for: user)
    }

    func delete(id: String) {

    }

    func search(with query: String, by user: User) -> ServicePublisher<[Medication]> {
        return self.db.search(query: query, by: user)
    }

}
