//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

protocol DatabaseService {
    // User functions
    func saveUser(user: User) -> ServicePublisher<Void>
    func getUser(userId: String) -> ServicePublisher<User>
    func deleteUser(user: User) -> ServicePublisher<Void>
    func findExistingUserWithGoogleAccount(googleId: String) -> ServicePublisher<User?>

    // LogSearchable functions
    func searchLogSearchables(query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]>
    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable>
    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void>

    // Log functions
    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void>
    func getLog(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?) -> ServicePublisher<[Loggable]>
    func deleteLog(for user: User, with id: String) -> ServicePublisher<Void>
}