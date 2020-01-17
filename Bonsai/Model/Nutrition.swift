import Foundation

struct NutritionItem: LogSearchable {
    let id: String
    let name: String
    let parentCategory: LogCategory = .nutrition
    let createdBy: String
}

struct NutritionLog: Loggable {
    let category: LogCategory = .nutrition
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
    let nutritionItemId: String
    let amount: String
    var selectedNutritionItem: NutritionItem? = nil
}