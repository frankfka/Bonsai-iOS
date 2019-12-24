//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Combine
import Foundation

protocol UserService {
    func createUser() -> User
    func save(user: User) -> ServicePublisher<Void>
    func get(userId: String) -> ServicePublisher<User>
}

class UserServiceImpl: UserService {
    let db: DatabaseService

    init(db: DatabaseService) {
        self.db = db
    }

    func createUser() -> User {
        let id = UUID().uuidString
        return User(id: id, dateCreated: Date())
    }

    func save(user: User) -> ServicePublisher<Void> {
        return self.db.save(user: user)
    }

    func get(userId: String) -> ServicePublisher<User> {
        return self.db.get(userId: userId)
    }
}