import Foundation
import SwiftUI

struct AppColors {
    // Text colors
    let Text: Color = Color(.label)
    let SecondaryText: Color = Color(.secondaryLabel)
    let TertiaryText: Color = Color(.tertiaryLabel)

    // Primary theme colors
    let PrimaryUIColor: UIColor = .systemGreen
    let Primary: Color = Color(.systemGreen)
    let Accent: Color = .orange
    let GrayscalePrimary: Color = Color(.systemGray)
    let GrayscaleSecondary: Color = Color(.systemGray3)
    
    // Generic conditional colors
    let Positive: Color = Color(.systemGreen)
    let Neutral: Color = Color(.systemOrange)
    let Negative: Color = Color(.systemRed)
    
    // Background colors
    let NavBarBackground: UIColor = .systemBackground
    let BackgroundPrimary: Color = Color(.systemGroupedBackground)
    let BackgroundSecondary: Color = Color(.secondarySystemGroupedBackground)
    let BackgroundPopup: Color = Color(.secondarySystemGroupedBackground)
    let Overlay: Color = Color(.systemGray3).opacity(0.5)
}

extension Color {
    static let Theme = AppColors()
}

struct CategoryColors {
    static let Mood = Color(.systemRed)
    static let Note = Color(.systemPurple)
    static let Medication = Color(.systemBlue)
    static let Nutrition = Color(.systemGreen)
    static let Activity = Color(.systemYellow)
    static let Symptom = Color(.systemOrange)
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
