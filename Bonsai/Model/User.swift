//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct User {
    let id: String
    let dateCreated: Date
    var linkedFirebaseGoogleAccount: FirebaseGoogleAccount?

    struct FirebaseGoogleAccount {
        let id: String
        let name: String
        let email: String
    }

    init(id: String, dateCreated: Date, linkedFirebaseGoogleAccount: FirebaseGoogleAccount? = nil) {
        self.id = id
        self.dateCreated = dateCreated
        self.linkedFirebaseGoogleAccount = linkedFirebaseGoogleAccount
    }
}