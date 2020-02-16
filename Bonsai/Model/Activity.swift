import Foundation
import RealmSwift

struct Activity: LogSearchable {
    let id: String
    let name: String
    let parentCategory: LogCategory = .activity
    let createdBy: String
}

struct ActivityLog: Loggable {
    let category: LogCategory = .activity
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
    let activityId: String
    let duration: TimeInterval
    var selectedActivity: Activity? = nil
}

class RealmActivityLog: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var activityId: String = ""
    @objc dynamic var durationRawValue: Double = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}
