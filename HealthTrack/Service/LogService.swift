//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Combine

protocol LogService {
    func save(log: Loggable) -> AnyPublisher<Void, ServiceError>
    func delete(id: String)
    func update(id: String, newLog: Loggable)
    func search(with query: String) -> AnyPublisher<[Medication], ServiceError>
}

class LogServiceImpl: LogService {
    private let db: DatabaseService

    init(db: DatabaseService) {
        self.db = db
    }

    func save(log: Loggable) -> AnyPublisher<Void, ServiceError> {
        
    }

    func delete(id: String) {

    }

    func update(id: String, newLog: Loggable) {

    }

    func search(with query: String) -> AnyPublisher<[Medication], ServiceError> {
        return self.db.search(query: query)
    }

}
