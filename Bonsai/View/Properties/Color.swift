import Foundation
import SwiftUI

struct AppColors {
    // Text colors
    let textDark: Color = Color.init(.label)
    let text: Color = Color.init(.secondaryLabel)
    let textLight: Color = Color.init(.tertiaryLabel)
    
    // Primary theme colors
    let primaryUIColor: UIColor = .systemGreen
    let primary: Color = Color.init(.systemGreen)
    let accent: Color = .orange
    let grayscalePrimary: Color = Color.init(.systemGray)
    let grayscaleSecondary: Color = Color.init(.systemGray3)
    
    // Generic conditional colors
    let positive: Color = Color.init(.systemGreen)
    let neutral: Color = Color.init(.systemOrange)
    let negative: Color = Color.init(.systemRed)
    
    // Background colors
    let backgroundPrimary: Color = Color.init(.systemGroupedBackground)
    let backgroundSecondary: Color = Color.init(.secondarySystemGroupedBackground)
    let overlay: Color = Color.init(.systemGray3).opacity(0.5)
    let popupBackground: Color = Color.init(.systemGray3)
}

extension Color {
    static let Theme = AppColors()
}

struct CategoryColors {
    static let Mood = Color.init(.systemRed)
    static let Note = Color.init(.systemPurple)
    static let Medication = Color.init(.systemBlue)
    static let Nutrition = Color.init(.systemGreen)
    static let Activity = Color.init(.systemYellow)
    static let Symptom = Color.init(.systemOrange)
}

extension LogCategory {
    func displayColor() -> Color {
        switch self {
        case .mood:
            return CategoryColors.Mood
        case .medication:
            return CategoryColors.Medication
        case .note:
            return CategoryColors.Note
        case .nutrition:
            return CategoryColors.Nutrition
        case .activity:
            return CategoryColors.Activity
        case .symptom:
            return CategoryColors.Symptom
        }
    }
}
