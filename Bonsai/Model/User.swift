//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct User {
    let id: String
    let dateCreated: Date
    var settings: Settings
    var linkedFirebaseGoogleAccount: FirebaseGoogleAccount?

    struct FirebaseGoogleAccount {
        let id: String
        let name: String
        let email: String
    }

    struct Settings {
        static let DefaultAnalyticsMoodRankDays: Int = 7
        static let DefaultAnalyticsSeverityDays: Int = 7

        // Analytics
        var analyticsMoodRankDays: Int
        var analyticsSymptomSeverityDays: Int

        init(analyticsMoodRankDays: Int? = nil, analyticsSymptomSeverityDays: Int? = nil) {
            self.analyticsMoodRankDays = analyticsMoodRankDays ?? Settings.DefaultAnalyticsMoodRankDays
            self.analyticsSymptomSeverityDays = analyticsSymptomSeverityDays ?? Settings.DefaultAnalyticsSeverityDays
        }
    }

    init(id: String, dateCreated: Date, settings: Settings, linkedFirebaseGoogleAccount: FirebaseGoogleAccount? = nil) {
        self.id = id
        self.dateCreated = dateCreated
        self.settings = settings
        self.linkedFirebaseGoogleAccount = linkedFirebaseGoogleAccount
    }
}
