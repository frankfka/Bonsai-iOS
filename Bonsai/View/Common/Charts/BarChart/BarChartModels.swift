//
// Created by Frank Jia on 2020-02-19.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI


struct BarChartDataPoint: Identifiable {
    let id = UUID()
    let relativeValue: CGFloat
    let barGradientColors: [Color]?
    var isValid: Bool {
        !(relativeValue < 0) || !(relativeValue > 1)
    }

    init(relativeValue: CGFloat, barColor: Color? = nil, barGradientColors: [Color]? = nil) {
        self.relativeValue = relativeValue
        if let barColor = barColor {
            self.barGradientColors = [barColor, barColor]
        } else if let gradientColors = barGradientColors, gradientColors.count > 1 {
            self.barGradientColors = barGradientColors
        } else {
            self.barGradientColors = nil
        }
    }
}

struct BarChartStyle {
    let barRadius: CGFloat
    let barSpacing: CGFloat
    let barGradientColors: [Color]

    init(barColor: Color = .black, barGradientColors: [Color]? = nil, barSpacing: CGFloat = 2, barRadius: CGFloat = 4) {
        self.barRadius = barRadius
        self.barSpacing = barSpacing
        if let gradientColors = barGradientColors, gradientColors.count > 1 {
            self.barGradientColors = gradientColors
        } else {
            self.barGradientColors = [barColor, barColor]
        }
    }
}