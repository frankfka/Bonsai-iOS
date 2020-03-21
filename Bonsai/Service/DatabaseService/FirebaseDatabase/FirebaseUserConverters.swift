//
// Created by Frank Jia on 2020-03-20.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// Extension to Encode/Decode User
extension User {
    func encode() -> [String: Any] {
        return [
            SerializationConstants.User.IdField: self.id,
            SerializationConstants.User.DateCreatedField: self.dateCreated,
            SerializationConstants.User.LinkedGoogleAccountField: self.linkedFirebaseGoogleAccount?.encode() as Any
        ]
    }

    static func decode(data: [String: Any]) -> User? {
        let userId = data[SerializationConstants.User.IdField] as? String
        let dateCreated = Date.fromFirebaseTimestamp(data[SerializationConstants.User.DateCreatedField])
        if let userId = userId, let dateCreated = dateCreated {
            // Linked Google account
            let linkedFirebaseAccount = decodeLinkedFirebaseAccount(data: data)
            // Settings
            let settings = decodeUserSettings(data: data)
            return User(id: userId, dateCreated: dateCreated, settings: settings, linkedFirebaseGoogleAccount: linkedFirebaseAccount)
        }
        return nil
    }

    static func decodeLinkedFirebaseAccount(data: [String: Any]) -> User.FirebaseGoogleAccount? {
        var linkedFirebaseAccount: FirebaseGoogleAccount? = nil
        if let linkedGoogleAccountData = data[SerializationConstants.User.LinkedGoogleAccountField] as? [String: Any],
           let googleAccount = FirebaseGoogleAccount.decode(data: linkedGoogleAccountData) {
            linkedFirebaseAccount = googleAccount
        }
        return linkedFirebaseAccount
    }

    static func decodeUserSettings(data: [String: Any]) -> User.Settings {
        var settings = User.Settings() // Start with defaults
        if let settingsData = data[SerializationConstants.User.SettingsField] as? [String: Any] {
            settings = User.Settings.decode(data: settingsData)
        }
        return settings
    }
}

// Extension to Encode/Decode Firebase Google Account
extension User.FirebaseGoogleAccount {
    func encode() -> [String: Any] {
        return [
            SerializationConstants.User.FirebaseGoogleAccount.IdField: self.id,
            SerializationConstants.User.FirebaseGoogleAccount.NameField: self.name,
            SerializationConstants.User.FirebaseGoogleAccount.EmailField: self.email
        ]
    }

    static func decode(data: [String: Any]) -> User.FirebaseGoogleAccount? {
        let googleId = data[SerializationConstants.User.FirebaseGoogleAccount.IdField] as? String
        let email = data[SerializationConstants.User.FirebaseGoogleAccount.EmailField] as? String
        // Name not currently needed
        let name = data[SerializationConstants.User.FirebaseGoogleAccount.NameField] as? String ?? ""
        if let googleId = googleId, let email = email {
            return User.FirebaseGoogleAccount(id: googleId, name: name, email: email)
        }
        return nil
    }
}

extension User.Settings {
    func encode() -> [String: Any] {
        return [
            SerializationConstants.User.Settings.AnalyticsMoodRankDays: self.analyticsMoodRankDays
        ]
    }

    static func decode(data: [String: Any]) -> User.Settings {
        let analyticsMoodRankDays = data[SerializationConstants.User.Settings.AnalyticsMoodRankDays] as? Int
        return User.Settings(
            analyticsMoodRankDays: analyticsMoodRankDays
        )
    }
}