//
// Created by Frank Jia on 2020-02-19.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// Data model for line charts
struct LineChartData {
    let dataPoints: [LineChartDataPoint]

    init(dataPoints: [LineChartDataPoint]) {
        self.dataPoints = dataPoints
                // Sort by increasing relative x
                .sorted { (a, b) in
                    a.xRel < b.xRel
                }
                // Make sure coordinates are valid relative coordinates
                .filter { coordinate in
                    coordinate.isValid
                }
    }
}

struct LineChartDataPoint: Identifiable {
    let xRel: CGFloat
    let yRel: CGFloat
    let marker: AnyView? // Marker to show for the data point

    let id = UUID()
    // View-specific information
    var isValid: Bool {
        !(xRel < 0 || xRel > 1) || !(yRel < 0 || yRel > 1)
    }
    var displayX: CGFloat {
        xRel
    }
    var displayY: CGFloat {
        // Display coordinates have origin at top instead of bottom
        1 - yRel
    }

    init(xRel: CGFloat, yRel: CGFloat, marker: AnyView? = nil) {
        self.xRel = xRel
        self.yRel = yRel
        self.marker = marker
    }
}

struct LineChartStyle {
    let smoothed: Bool
    let lineColor: Color
    let lineStrokeStyle: StrokeStyle

    init(lineColor: Color = .black, lineStrokeStyle: StrokeStyle = StrokeStyle(), smoothed: Bool = false) {
        self.smoothed = smoothed
        self.lineColor = lineColor
        self.lineStrokeStyle = lineStrokeStyle
    }
}