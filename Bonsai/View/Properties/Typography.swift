import Foundation
import SwiftUI

struct AppTypography {
    let heading: Font = .system(size: CGFloat.Theme.Font.large, weight: .semibold, design: .default)
    let normalText: Font = .system(size: CGFloat.Theme.Font.normal, weight: .regular, design: .default)
    let normalTextUIFont: UIFont = .systemFont(ofSize: CGFloat.Theme.Font.normal, weight: .regular)
    let subtext: Font = .system(size: CGFloat.Theme.Font.small, weight: .regular, design: .default)
    
    let largeBoldText: Font = .system(size: CGFloat.Theme.Font.large, weight: .medium, design: .default)
    let normalBoldText: Font = .system(size: CGFloat.Theme.Font.normal, weight: .medium, design: .default)
    
    let normalIcon: Font = .system(size: CGFloat.Theme.Font.normalIcon)
    let smallIcon: Font = .system(size: CGFloat.Theme.Font.smallIcon)
}

extension Font {
    static let Theme = AppTypography()
}
