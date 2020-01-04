import Foundation

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
}