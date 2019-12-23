import Foundation
import SwiftUI

struct AppIcons {

    let todoEmpty: Image
    let todoFilled: Image
    
    let info: Image
    
    init() {
        todoEmpty = Image(systemName: "circle")
        todoFilled = Image(systemName: "circle.fill")
        
        info = Image(systemName: "info.circle.fill")
    }
    
}

extension Image {
    static let Icons = AppIcons()
}
