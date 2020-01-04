import Foundation

struct Symptom: LogSearchable {
    let id: String
    let name: String
    let parentCategory: LogCategory = .symptom
    let createdBy: String
}

struct SymptomLog: Loggable {

    enum Severity: Int {
        case none = 0
        case mild = 10
        case normal = 20
        case severe = 30
        case extreme = 40
    }

    let category: LogCategory = .symptom
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
    let symptomId: String
    let severity: Severity
}