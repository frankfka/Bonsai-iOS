//
//  PastWeekMoodChartView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-02-20.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    private static var moodAnalyticsAxisFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    static func stringForMoodAnalyticsAxis(from date: Date) -> String {
        return moodAnalyticsAxisFormatter.string(from: date)
    }
}

struct HistoricalMoodChartView: View {

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
        // TODO: different color for different averages?
        static let averageMoodLineChartStyle = LineChartStyle(
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
        static private let maxMoodRankValue = CGFloat(MoodRank.positive.rawValue)
        static private let minMoodRankValue = CGFloat(MoodRank.negative.rawValue)
        static private let buffer: CGFloat = (maxMoodRankValue - minMoodRankValue) * 0.2
        static private let minChartValue: CGFloat = minMoodRankValue - buffer
        static private let maxChartValue: CGFloat = maxMoodRankValue + buffer
        static private let chartRange: CGFloat = maxChartValue - minChartValue
        static private func getRelativeValue(_ val: CGFloat) -> CGFloat { (val - minChartValue) / chartRange }
        // Axis Lines
        static let positiveMoodAxisLineChartData = LineChartData(dataPoints: [
            LineChartDataPoint(xRel: 0, yRel: getRelativeValue(CGFloat(MoodRank.positive.rawValue))),
            LineChartDataPoint(xRel: 1, yRel: getRelativeValue(CGFloat(MoodRank.positive.rawValue)))
        ])
        static let neutralMoodAxisLineChartData = LineChartData(dataPoints: [
            LineChartDataPoint(xRel: 0, yRel: getRelativeValue(CGFloat(MoodRank.neutral.rawValue))),
            LineChartDataPoint(xRel: 1, yRel: getRelativeValue(CGFloat(MoodRank.neutral.rawValue)))
        ])
        static let negativeMoodAxisLineChartData = LineChartData(dataPoints: [
            LineChartDataPoint(xRel: 0, yRel: getRelativeValue(CGFloat(MoodRank.negative.rawValue))),
            LineChartDataPoint(xRel: 1, yRel: getRelativeValue(CGFloat(MoodRank.negative.rawValue)))
        ])
        
        let axisLabels: [(fullDisplay: String, shortDisplay: String)]
        var useFullAxisLabels: Bool {
            // TODO: Use width to determine this
            dailyMoodBarChartData.count < 10
        }
        let dailyMoodBarChartData: [BarChartDataPoint]
        let avgMoodLineChartData: LineChartData
        let showNoDataText: Bool
        
        init(analytics: MoodRankAnalytics) {
            var showNoDataText = true
            // Bar Chart
            var axisLabels: [(fullDisplay: String, shortDisplay: String)] = []
            var barChartDataPoints: [BarChartDataPoint] = []
            for day in analytics.moodRankDays {
                let dateString = DateFormatter.stringForMoodAnalyticsAxis(from: day.date)
                // Short display is used for lengthier datasets
                axisLabels.append((fullDisplay: dateString, shortDisplay: String(dateString.prefix(1))))
                let relativeValue: CGFloat
                if let averageValue = day.averageMoodRankValue {
                    relativeValue = ViewModel.getRelativeValue(CGFloat(averageValue))
                    showNoDataText = false
                } else {
                    relativeValue = 0
                }
                barChartDataPoints.append(BarChartDataPoint(relativeValue: relativeValue))
            }
            
            // Line Chart
            var lineChartDataPoints: [LineChartDataPoint] = []
            if let averageMood = analytics.averageMoodRankValue {
                let relMoodValue = ViewModel.getRelativeValue(CGFloat(averageMood))
                lineChartDataPoints = [LineChartDataPoint(xRel: 0, yRel: relMoodValue),
                                       LineChartDataPoint(xRel: 1, yRel: relMoodValue)]
            }
            
            // Initialize
            self.avgMoodLineChartData = LineChartData(dataPoints: lineChartDataPoints)
            self.dailyMoodBarChartData = barChartDataPoints
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
                // Show prompt if no data exists for past week
                Text("No Mood Data")
                    .font(Font.Theme.normalText)
                    .foregroundColor(Color.Theme.text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Otherwise, show charts
                ChartView {
                    // Background axes
                    LineChartComponent(
                            data: ViewModel.positiveMoodAxisLineChartData,
                            style: ViewModel.axisLineChartStyle
                    )
                    LineChartComponent(
                            data: ViewModel.neutralMoodAxisLineChartData,
                            style: ViewModel.axisLineChartStyle
                    )
                    LineChartComponent(
                            data: ViewModel.negativeMoodAxisLineChartData,
                            style: ViewModel.axisLineChartStyle
                    )
                    // Bar chart values per day
                    Group {
                        // Background so that the foreground bar chart can be somewhat transparent
                        BarChartComponent(
                            data: self.viewModel.dailyMoodBarChartData,
                            style: ViewModel.barChartBackgroundStyle
                        )
                        BarChartComponent(
                            data: self.viewModel.dailyMoodBarChartData,
                            style: ViewModel.barChartStyle
                        )
                    }
                    .padding(.horizontal, ViewModel.barChartPadding)
                    LineChartComponent(
                        data: self.viewModel.avgMoodLineChartData,
                        style: ViewModel.averageMoodLineChartStyle
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

struct PastWeekMoodChartView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            HistoricalMoodChartView(viewModel: HistoricalMoodChartView.ViewModel(analytics: AnalyticsPreviews.HistoricalMoodPastWeekWithData))
            
            HistoricalMoodChartView(viewModel: HistoricalMoodChartView.ViewModel(analytics: AnalyticsPreviews.HistoricalMoodPastWeekWithData))
                .environment(\.colorScheme, .dark)
            
            HistoricalMoodChartView(viewModel: HistoricalMoodChartView.ViewModel(analytics: AnalyticsPreviews.HistoricalMoodPastWeekWithNoData))
        }
        .frame(width: 500, height: 300)
        .background(Color.Theme.backgroundSecondary)
        .previewLayout(.sizeThatFits)
    }
}
