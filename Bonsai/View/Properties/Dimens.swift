import Foundation
import SwiftUI

struct AppDimensions {
    
    let Font = AppFontSize()
    let Layout = AppLayout()
    let Charts = AppCharts()
    let Misc = AppMisc()
    
    struct AppFontSize {
        let small: CGFloat = 12
        let normal: CGFloat = 16
        let large: CGFloat = 20

        let popupIcon: CGFloat = 48
        let largeIcon: CGFloat = 24
        let normalIcon: CGFloat = 16
        let smallIcon: CGFloat = 12
    }
    
    struct AppLayout {
        // Padding
        let large: CGFloat = 24
        let normal: CGFloat = 16
        let small: CGFloat = 8
        let extraSmall: CGFloat = 4
        let rowSeparator: CGFloat = 16 // Padding between elements aligned on left and right of the row
        
        let cornerRadius: CGFloat = 24
        
        let tabItemHeight: CGFloat = 60
        let navBarItemHeight: CGFloat = 24
        let popupFrameSize: CGFloat = 96

        let minSectionHeight: CGFloat = 150
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
        let spinnerSizeSmall: CGFloat = 24
        let spinnerSizeNormal: CGFloat = 48
    }
    
}

extension CGFloat {
    static let Theme = AppDimensions()
}
