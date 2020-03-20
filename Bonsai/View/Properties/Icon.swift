import Foundation
import SwiftUI

struct AppIcons {

    let todoEmpty: Image = Image(systemName: "circle")
    let todoFilled: Image = Image(systemName: "circle.fill")
    
    let info: Image = Image(systemName: "info.circle.fill")
}

extension Image {
    static let Icons = AppIcons()
}
