//
//  HistoricalSymptomSeverityView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-04-03.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    private static var symptomSeverityAxisFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }

    static func stringForSymptomSeverityAxis(from date: Date) -> String {
        return symptomSeverityAxisFormatter.string(from: date)
    }
}

// TODO: Consolidate this and mood chart?
struct HistoricalSymptomSeverityView: View {

    struct ViewModel {
        static let minChartHeight: CGFloat = 200 // TODO: Somehow make this not a constant
        static let barChartStyle = BarChartStyle(
                barColor: Color.Theme.positive.opacity(0.8),
                barSpacing: CGFloat.Theme.Charts.barSpacing,
                barRadius: CGFloat.Theme.Charts.barCornerRadius
        )
        static let barChartBackgroundStyle = BarChartStyle(
                barColor: Color.white,
                barSpacing: CGFloat.Theme.Charts.barSpacing,
                barRadius: CGFloat.Theme.Charts.barCornerRadius
        )
        static let barChartPadding: CGFloat = 8
        static let averageLineChartStyle = LineChartStyle(
                lineColor: Color.Theme.accent.opacity(0.8),
                lineStrokeStyle: StrokeStyle(lineWidth: CGFloat.Theme.Charts.normalLineWidth),
                smoothed: false
        )
        // Used for background axis lines
        static let axisLineChartStyle = LineChartStyle(
                lineColor: Color.Theme.grayscalePrimary.opacity(0.2),
                lineStrokeStyle: StrokeStyle(lineWidth: CGFloat.Theme.Charts.thinLineWidth),
                smoothed: false
        )

        // For calculation of relative values
        static private let maxValue = CGFloat(SymptomLog.Severity.extreme.rawValue)
        static private let minValue = CGFloat(SymptomLog.Severity.none.rawValue)
        static private let buffer: CGFloat = (maxValue - minValue) * 0.2
        static private let minChartValue: CGFloat = minValue - buffer
        static private let maxChartValue: CGFloat = maxValue + buffer
        static private let chartRange: CGFloat = maxChartValue - minChartValue
        static private func getRelativeValue(_ val: CGFloat) -> CGFloat { (val - minChartValue) / chartRange }
        // Axis Lines
        static let axisLineChartData: [LineChartData] = SymptomLog.Severity.allCases.map {
            LineChartData(dataPoints: [
                LineChartDataPoint(xRel: 0, yRel: getRelativeValue(CGFloat($0.rawValue))),
                LineChartDataPoint(xRel: 1, yRel: getRelativeValue(CGFloat($0.rawValue)))
            ])
        }

        let axisLabels: [(fullDisplay: String, shortDisplay: String)]
        var useFullAxisLabels: Bool {
            // TODO: Use width to determine this
            barChartData.count < 10
        }
        let barChartData: [BarChartDataPoint]
        let averageLineChartData: LineChartData
        let showNoDataText: Bool

        init(analytics: SymptomSeverityAnalytics) {
            var showNoDataText = true
            // Bar Chart
            var axisLabels: [(fullDisplay: String, shortDisplay: String)] = []
            var barChartDataPoints: [BarChartDataPoint] = []
            for day in analytics.severityDaySummaries {
                let dateString = DateFormatter.stringForSymptomSeverityAxis(from: day.date)
                // Short display is used for lengthier datasets
                axisLabels.append((fullDisplay: dateString, shortDisplay: String(dateString.prefix(1))))
                let relativeValue: CGFloat
                if let averageValue = day.averageSeverityValue {
                    relativeValue = ViewModel.getRelativeValue(CGFloat(averageValue))
                    showNoDataText = false
                } else {
                    relativeValue = 0
                }
                barChartDataPoints.append(BarChartDataPoint(relativeValue: relativeValue))
            }

            // Line Chart
            var lineChartDataPoints: [LineChartDataPoint] = []
            if let averageSeverity = analytics.averageSeverityValue {
                let relValue = ViewModel.getRelativeValue(CGFloat(averageSeverity))
                lineChartDataPoints = [LineChartDataPoint(xRel: 0, yRel: relValue),
                                       LineChartDataPoint(xRel: 1, yRel: relValue)]
            }

            // Initialize
            self.averageLineChartData = LineChartData(dataPoints: lineChartDataPoints)
            self.barChartData = barChartDataPoints
            self.axisLabels = axisLabels
            self.showNoDataText = showNoDataText
        }
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center) {
            if viewModel.showNoDataText {
                // This should never occur, as symptom analytics will include at least one data point
                Text("No Data Available")
                        .font(Font.Theme.normalText)
                        .foregroundColor(Color.Theme.text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Otherwise, show charts
                ChartView {
                    // Background axes
                    ForEach(0..<ViewModel.axisLineChartData.count, id: \.self) {
                        LineChartComponent(
                            data: ViewModel.axisLineChartData[$0],
                            style: ViewModel.axisLineChartStyle
                        )
                    }
                    // Bar chart values per day
                    Group {
                        // Background so that the foreground bar chart can be somewhat transparent
                        BarChartComponent(
                                data: self.viewModel.barChartData,
                                style: ViewModel.barChartBackgroundStyle
                        )
                        BarChartComponent(
                                data: self.viewModel.barChartData,
                                style: ViewModel.barChartStyle
                        )
                    }
                    .padding(.horizontal, ViewModel.barChartPadding)
                    LineChartComponent(
                            data: self.viewModel.averageLineChartData,
                            style: ViewModel.averageLineChartStyle
                    )
                }
            }
            // Bottom Axis
            HStack {
                ForEach(viewModel.axisLabels, id: \.fullDisplay) { label in
                    Text(self.viewModel.useFullAxisLabels ? label.fullDisplay : label.shortDisplay)
                        .font(Font.Theme.subtext)
                        .foregroundColor(Color.Theme.text)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, ViewModel.barChartPadding)
        }.frame(minHeight: ViewModel.minChartHeight)
    }
}

struct HistoricalSymptomSeverityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HistoricalSymptomSeverityView(viewModel: HistoricalSymptomSeverityView.ViewModel(analytics: AnalyticsPreviews.HistoricalSeverityPastWeek))
            .background(Color.Theme.backgroundSecondary)

            
            HistoricalSymptomSeverityView(viewModel: HistoricalSymptomSeverityView.ViewModel(analytics: AnalyticsPreviews.HistoricalSeverityPastWeek))
            .background(Color.Theme.backgroundSecondary)
                .colorScheme(.dark)
        }
        .frame(width: 500, height: 300)
        .previewLayout(.sizeThatFits)
    }
}
