import Foundation
import SwiftUI

struct AppDimensions {
    
    let Font = AppFontSize()
    let Layout = AppLayout()
    let Misc = AppMisc()
    
    struct AppFontSize {
        let small: CGFloat!
        let normal: CGFloat!
        let large: CGFloat!
        
        let largeIcon: CGFloat!
        let normalIcon: CGFloat!
        let smallIcon: CGFloat!
        
        init() {
            small = 12
            normal = 16
            large = 20
            
            largeIcon = 24
            normalIcon = 16
            smallIcon = 12
        }
    }
    
    struct AppLayout {
        // Padding
        let normal: CGFloat!
        let small: CGFloat!
        
        let cornerRadius: CGFloat!
        
        let tabItemHeight: CGFloat!
        
        init() {
            normal = 16
            small = 8
            
            cornerRadius = 24
            
            tabItemHeight = 60
        }
    }
    
    struct AppMisc {
        // Spinner
        let spinnerSizeSmall: CGFloat!
        let spinnerSizeNormal: CGFloat!
        
        init() {
            spinnerSizeSmall = 24
            spinnerSizeNormal = 48
        }
    }
    
}

extension CGFloat {
    static let Theme = AppDimensions()
}
