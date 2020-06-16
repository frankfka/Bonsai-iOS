import Foundation
import SwiftUI

struct AppDimensions {
    
    let Font = AppFontSize()
    let Layout = AppLayout()
    let Charts = AppCharts()
    let Misc = AppMisc()
    
    struct AppFontSize {
        let Small: CGFloat = 12
        let Normal: CGFloat = 16
        let Large: CGFloat = 20

        let PopupIcon: CGFloat = 48
        let LargeIcon: CGFloat = 24
        let NormalIcon: CGFloat = 16
        let SmallIcon: CGFloat = 12
    }
    
    struct AppLayout {
        // Padding
        let Large: CGFloat = 24
        let Normal: CGFloat = 16
        let Small: CGFloat = 8
        let ExtraSmall: CGFloat = 4
        let RowSeparator: CGFloat = 16 // Padding between elements aligned on left and right of the row
        
        let CornerRadius: CGFloat = 24
        
        let TabItemHeight: CGFloat = 60
        let NavBarItemHeight: CGFloat = 24
        let PopupFrameSize: CGFloat = 96

        let MinSectionHeight: CGFloat = 150
    }

    struct AppCharts {
        // Bar
        let BarSpacing: CGFloat = 4
        let BarCornerRadius: CGFloat = 16

        // Line
        let ThinLineWidth: CGFloat = 1
        let NormalLineWidth: CGFloat = 4
    }
    
    struct AppMisc {
        // Spinner
        let SpinnerSizeSmall: CGFloat = 24
        let SpinnerSizeNormal: CGFloat = 48
    }
    
}

extension CGFloat {
    static let Theme = AppDimensions()
}
