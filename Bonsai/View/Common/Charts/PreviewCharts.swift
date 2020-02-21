//
// Created by Frank Jia on 2020-02-20.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct PreviewCharts {
    // Bar Charts
    static var BarChartData: [BarChartDataPoint] = [
        BarChartDataPoint(relativeValue: 0.2),
        BarChartDataPoint(relativeValue: 0.4),
        BarChartDataPoint(relativeValue: 0.5),
        BarChartDataPoint(relativeValue: 0.1),
        BarChartDataPoint(relativeValue: 0.8),
        BarChartDataPoint(relativeValue: 1)
    ]
    static var AppBarChartStyle: BarChartStyle = BarChartStyle(
            barGradientColors: [Color.Theme.positive, Color.Theme.positive, Color.Theme.neutral, Color.Theme.negative],
            barRadius: CGFloat.Theme.Layout.cornerRadius
    )

    // Line Charts
    static var LineChartMarker: AnyView = Circle()
            .foregroundColor(Color.Theme.neutral)
            .frame(width: 4, height: 4)
            .eraseToAnyView()

    static var LineChartDynamicData: LineChartData = LineChartData(
            dataPoints: [
                LineChartDataPoint(xRel: 0, yRel: 0.1, marker: LineChartMarker),
                LineChartDataPoint(xRel: 0.2, yRel: 0.4),
                LineChartDataPoint(xRel: 0.4, yRel: 0.6),
                LineChartDataPoint(xRel: 0.6, yRel: 0.2, marker: LineChartMarker),
                LineChartDataPoint(xRel: 0.8, yRel: 1),
                LineChartDataPoint(xRel: 1, yRel: 0.4)
            ]
    )
    static var LineChartConstantData: LineChartData = LineChartData(
            dataPoints: [
                LineChartDataPoint(xRel: 0, yRel: 0.5),
                LineChartDataPoint(xRel: 1, yRel: 0.5)
            ]
    )

    static var AppLineChartStyle: LineChartStyle = LineChartStyle(
            lineColor: Color.Theme.primary,
            lineStrokeStyle: StrokeStyle(),
            smoothed: true
    )
}
