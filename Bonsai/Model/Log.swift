//
//  Log.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

// Protocol that searchable log items conform to
protocol LogSearchable {
    var id: String { get }
    var name: String { get }
    var parentCategory: LogCategory { get }
    var createdBy: String { get }
}

// Protocol that each log type conforms to
protocol Loggable {
    var id: String { get }
    // Add redundant title property to facilitate nosql structure, this way we save a lot of lookups
    var title: String { get }
    var dateCreated: Date { get }
    var category: LogCategory { get }
    var notes: String { get }
}

// Stored by Realm - has references to additional information depending on the category
class RealmLoggable: Object {
    @objc dynamic var categoryRawValue: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var notes: String = ""
    @objc dynamic var medicationLog: RealmMedicationLog?
    @objc dynamic var moodLog: RealmMoodLog?
    @objc dynamic var nutritionLog: RealmNutritionLog?
    @objc dynamic var symptomLog: RealmSymptomLog?
    @objc dynamic var activityLog: RealmActivityLog?
    @objc dynamic var isTemplate: Bool = false // Used for reminders

    static let dateCreatedKey: String = "dateCreated"
    static let isTemplateKey: String = "isTemplate"

    override static func primaryKey() -> String? {
        return "id"
    }
}

enum LogCategory: CaseIterable {
    case note
    case symptom
    case nutrition
    case activity
    case mood
    case medication
    
    func displayValue(plural: Bool = false) -> String {
        switch self {
        case .note:
            return "Note" + (plural ? "s" : "")
        case .symptom:
            return "Symptom" + (plural ? "s" : "")
        case .nutrition:
            return "Nutrition"
        case .activity:
            return "Activit" + (plural ? "ies" : "y")
        case .mood:
            return "Mood" + (plural ? "s" : "")
        case .medication:
            return "Medication" + (plural ? "s" : "")
        }
    }

    func serializedLogCategoryName() -> String {
        switch self {
        case .mood:
            return SerializationConstants.Logs.Mood.CategoryName
        case .medication:
            return SerializationConstants.Logs.Medication.CategoryName
        case .nutrition:
            return SerializationConstants.Logs.Nutrition.CategoryName
        case .activity:
            return SerializationConstants.Logs.Activity.CategoryName
        case .symptom:
            return SerializationConstants.Logs.Symptom.CategoryName
        case .note:
            return SerializationConstants.Logs.Note.CategoryName
        }
    }

    static func fromSerializedLogCategoryName(_ name: String) -> LogCategory? {
        switch name {
        case SerializationConstants.Logs.Medication.CategoryName:
            return .medication
        case SerializationConstants.Logs.Mood.CategoryName:
            return .mood
        case SerializationConstants.Logs.Nutrition.CategoryName:
            return .nutrition
        case SerializationConstants.Logs.Activity.CategoryName:
            return .activity
        case SerializationConstants.Logs.Symptom.CategoryName:
            return .symptom
        case SerializationConstants.Logs.Note.CategoryName:
            return .note
        default:
            break
        }
        AppLogging.warn("Invalid firebase log category \(name)")
        return nil
    }

}
