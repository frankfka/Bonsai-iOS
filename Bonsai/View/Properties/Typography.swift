import Foundation
import SwiftUI

struct AppTypography {
    
    let heading: Font!
    let normalText: Font!
    let normalTextUIFont: UIFont!
    let subtext: Font!
    
    let boldAccentText: Font!
    let boldNormalText: Font!
    
    let normalIcon: Font!
    let smallIcon: Font!
    
    init() {
        heading = .system(size: CGFloat.Theme.Font.large, weight: .semibold, design: .default)
        normalText = .system(size: CGFloat.Theme.Font.normal, weight: .medium, design: .default)
        normalTextUIFont = .systemFont(ofSize: CGFloat.Theme.Font.normal, weight: .medium)
        subtext = .system(size: CGFloat.Theme.Font.small, weight: .medium, design: .default)
        
        boldAccentText = .system(size: CGFloat.Theme.Font.large, weight: .medium, design: .default)
        boldNormalText = .system(size: CGFloat.Theme.Font.normal, weight: .medium, design: .default)
        
        normalIcon = .system(size: CGFloat.Theme.Font.normalIcon)
        smallIcon = .system(size: CGFloat.Theme.Font.smallIcon)
        
    }
}

extension Font {
    static let Theme = AppTypography()
}
