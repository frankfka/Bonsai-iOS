import Foundation
import SwiftUI

struct AppTypography {
    let Heading: Font = .system(size: CGFloat.Theme.Font.Large, weight: .semibold, design: .default)
    let NormalText: Font = .system(size: CGFloat.Theme.Font.Normal, weight: .regular, design: .default)
    let NormalTextUIFont: UIFont = .systemFont(ofSize: CGFloat.Theme.Font.Normal, weight: .regular)
    let SmallText: Font = .system(size: CGFloat.Theme.Font.Small, weight: .regular, design: .default)
    
    let LargeBoldText: Font = .system(size: CGFloat.Theme.Font.Large, weight: .medium, design: .default)
    let NormalBoldText: Font = .system(size: CGFloat.Theme.Font.Normal, weight: .medium, design: .default)
    
    let NormalIcon: Font = .system(size: CGFloat.Theme.Font.NormalIcon)
    let SmallIcon: Font = .system(size: CGFloat.Theme.Font.SmallIcon)
}

extension Font {
    static let Theme = AppTypography()
}
