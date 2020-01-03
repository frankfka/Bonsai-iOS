import Foundation

struct NutritionItem: LogSearchable {
    let id: String
    let name: String
    let parentCategory: LogCategory = .nutrition
    let createdBy: String

}
