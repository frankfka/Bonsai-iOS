//
// Created by Frank Jia on 2020-03-06.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: Configuration and Migrations
extension RealmService {
    static let AppRealmConfiguration = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldVersion in
        if oldVersion < 1 {
            version1Migration(migration: migration)
        }
    })

    /*
    Version 1
    - Add RealmLogReminder
    - Add isTemplate to RealmLoggable
    */
    private static func version1Migration(migration: Migration) {
        migration.enumerateObjects(ofType: RealmLoggable.className()) { _, new in
            // Add isTemplate = false
            new![RealmLoggable.isTemplateKey] = false
        }
    }
}
