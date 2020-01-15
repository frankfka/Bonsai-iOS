import Foundation

struct Symptom: LogSearchable {
    let id: String
    let name: String
    let parentCategory: LogCategory = .symptom
    let createdBy: String
}

struct SymptomLog: Loggable {

    enum Severity: Double, CaseIterable {
        case none = 0.0
        case mild = 10.0
        case normal = 20.0
        case severe = 30.0
        case extreme = 40.0
        static let least: Severity = .none
        static let most: Severity = .extreme
        static var range: Double {
            most.rawValue - least.rawValue
        }
        static var numCases: Int {
            Severity.allCases.count
        }
        static var increment: Double {
            Severity.range / Double(Severity.numCases - 1)
        }

        func displayValue() -> String {
            switch self {
            case .none:
                return "None"
            case .mild:
                return "Mild"
            case .normal:
                return "Normal"
            case .severe:
                return "Severe"
            case .extreme:
                return "Extreme"
            }
        }

    }

    let category: LogCategory = .symptom
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
    let symptomId: String
    let severity: Severity
}