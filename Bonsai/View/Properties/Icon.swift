import Foundation
import SwiftUI

struct AppIcons {

    let TodoEmpty: Image = Image(systemName: "circle")
    let TodoFilled: Image = Image(systemName: "circle.fill")
    
    let Info: Image = Image(systemName: "info.circle.fill")
}

extension Image {
    static let Icons = AppIcons()
}
