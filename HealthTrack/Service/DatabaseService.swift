//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

protocol DatabaseService {
    // User functions
    func save(user: User) -> ServicePublisher<Void>
    func get(userId: String) -> ServicePublisher<User>

    // Search functions
    func search(query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]>

    // Log Save functions
    func save(logItem: LogSearchable, for user: User) -> ServicePublisher<Void>
    func save(log: Loggable, for user: User) -> ServicePublisher<Void>

    // Log Get functions
    func get(for user: User, in category: LogCategory?, since date: Date?) -> ServicePublisher<[Loggable]>
}