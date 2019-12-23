import Foundation
import SwiftUI

struct AppColors {
    
    // Text colors
    let textDark: Color!
    let text: Color!
    let textLight: Color!
    
    // Primary theme colors
    let primaryUIColor: UIColor!
    let primary: Color!
    let grayscalePrimary: Color!
    let grayscaleSecondary: Color!
    
    // Generic conditional colors
    let positive: Color!
    let neutral: Color!
    let negative: Color!
    
    // Background colors
    let backgroundPrimary: Color!
    let backgroundSecondary: Color!
    let overlay: Color!
    
    init() {
        textDark = Color.init(.label)
        text = Color.init(.secondaryLabel)
        textLight = Color.init(.tertiaryLabel)
        
        primaryUIColor = .systemGreen
        primary = Color.init(.systemGreen)
        grayscalePrimary = Color.init(.systemGray)
        grayscaleSecondary = Color.init(.systemGray3)
        
        positive = Color.init(.systemGreen)
        neutral = Color.init(.systemOrange)
        negative = Color.init(.systemRed)
        
        backgroundPrimary = Color.init(.systemGroupedBackground)
        backgroundSecondary = Color.init(.secondarySystemGroupedBackground)
        overlay = Color.init(.systemBackground).opacity(0.5)
    }
}

extension Color {
    static let Theme = AppColors()
}
