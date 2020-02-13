import Foundation
import RealmSwift

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

class RealmNutritionLog: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var nutritionItemId: String = ""
    @objc dynamic var amount: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
