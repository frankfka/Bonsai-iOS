import Foundation
import SwiftUI

struct AppDimensions {
    
    let Font = AppFontSize()
    let Layout = AppLayout()
    let Charts = AppCharts()
    let Misc = AppMisc()
    
    struct AppFontSize {
        let small: CGFloat!
        let normal: CGFloat!
        let large: CGFloat!

        let popupIcon: CGFloat!
        let largeIcon: CGFloat!
        let normalIcon: CGFloat!
        let smallIcon: CGFloat!
        
        init() {
            small = 12
            normal = 16
            large = 20

            popupIcon = 48
            largeIcon = 24
            normalIcon = 16
            smallIcon = 12
        }
    }
    
    struct AppLayout {
        // Padding
        let large: CGFloat = 24
        let normal: CGFloat!
        let small: CGFloat!
        let rowSeparator: CGFloat! // Padding between elements aligned on left and right of the row
        
        let cornerRadius: CGFloat!
        
        let tabItemHeight: CGFloat!
        let navBarItemHeight: CGFloat!
        let popupFrameSize: CGFloat!

        let minSectionHeight: CGFloat = 150
        
        init() {
            normal = 16
            small = 8
            rowSeparator = 16
            
            cornerRadius = 24
            
            tabItemHeight = 60
            navBarItemHeight = 24
            popupFrameSize = 96
        }
    }

    struct AppCharts {
        // Bar
        let barSpacing: CGFloat = 4
        let barCornerRadius: CGFloat = 16

        // Line
        let thinLineWidth: CGFloat = 1
        let normalLineWidth: CGFloat = 4
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
