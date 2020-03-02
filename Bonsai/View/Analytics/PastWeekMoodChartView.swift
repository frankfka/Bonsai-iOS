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

struct PastWeekMoodChartView: View {
    
    struct ViewModel {
        static let barChartStyle = BarChartStyle(
            barColor: Color.Theme.positive.opacity(0.8),
            barSpacing: CGFloat.Theme.Charts.barSpacing,
            barRadius: CGFloat.Theme.Charts.barCornerRadius
        )
        static let barChartPadding: CGFloat = 8
        // TODO: different color for different averages?
        static let lineChartStyle = LineChartStyle(
            lineColor: Color.Theme.accent.opacity(0.8),
            lineStrokeStyle: StrokeStyle(lineWidth: CGFloat.Theme.Charts.lineWidth),
            smoothed: false
        )
        
        let axisLabels: [String]
        let barChartData: [BarChartDataPoint]
        let lineChartData: LineChartData
        let showNoDataText: Bool
        
        init(analytics: MoodRankAnalytics) {
            var showNoDataText = true
            // Bar Chart
            var axisLabels: [String] = []
            var barChartDataPoints: [BarChartDataPoint] = []
            var minValue: CGFloat = CGFloat(MoodRank.negative.rawValue)
            var maxValue: CGFloat = CGFloat(MoodRank.positive.rawValue)
            let buffer = (maxValue - minValue) * 0.1
            minValue = minValue - buffer
            maxValue = maxValue + buffer
            let range = maxValue - minValue
            for day in analytics.moodRankDays {
                axisLabels.append(DateFormatter.stringForMoodAnalyticsAxis(from: day.date))
                let relativeValue: CGFloat
                if let averageValue = day.averageMoodRankValue {
                    relativeValue = (CGFloat(averageValue) - minValue) / range
                    showNoDataText = false
                } else {
                    relativeValue = 0
                }
                barChartDataPoints.append(BarChartDataPoint(relativeValue: relativeValue))
            }
            
            // Line Chart
            var lineChartDataPoints: [LineChartDataPoint] = []
            if let averageMood = analytics.averageMoodRankValue {
                let relMoodValue = (CGFloat(averageMood) - minValue) / range
                lineChartDataPoints = [LineChartDataPoint(xRel: 0, yRel: relMoodValue),
                                       LineChartDataPoint(xRel: 1, yRel: relMoodValue)]
            }
            
            // Initialize
            self.lineChartData = LineChartData(dataPoints: lineChartDataPoints)
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
                // Show prompt if no data exists for past week
                Text("No Mood Data")
                    .font(Font.Theme.normalText)
                    .foregroundColor(Color.Theme.text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Otherwise, show charts
                ChartView {
                    BarChartComponent(
                        data: self.viewModel.barChartData,
                        style: ViewModel.barChartStyle
                    )
                    .padding(.horizontal, ViewModel.barChartPadding)
                    LineChartComponent(
                        data: self.viewModel.lineChartData,
                        style: ViewModel.lineChartStyle
                    )
                }
            }
            // Bottom Axis
            HStack {
                ForEach(viewModel.axisLabels, id: \.self) { label in
                    Text(label)
                        .font(Font.Theme.normalText)
                        .foregroundColor(Color.Theme.text)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, ViewModel.barChartPadding)
        }
    }
}

struct PastWeekMoodChartView_Previews: PreviewProvider {
    
    private static var negativeMood: Double = Double(MoodRank.negative.rawValue)
    private static var neutralMood: Double = Double(MoodRank.neutral.rawValue)
    private static var positiveMood: Double = Double(MoodRank.positive.rawValue)
    
    static var pastWeekWithData: MoodRankAnalytics = MoodRankAnalytics(
        moodRankDays: [
            MoodRankDaySummary(date: Date().addingTimeInterval(-7 * TimeInterval.day), averageMoodRankValue: positiveMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-6 * TimeInterval.day), averageMoodRankValue: neutralMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-5 * TimeInterval.day), averageMoodRankValue: negativeMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-4 * TimeInterval.day), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-3 * TimeInterval.day), averageMoodRankValue: neutralMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-2 * TimeInterval.day), averageMoodRankValue: (negativeMood + neutralMood) / 2.0),
            MoodRankDaySummary(date: Date().addingTimeInterval(-TimeInterval.day), averageMoodRankValue: negativeMood)
        ]
    )
    
    static var pastWeekWithNoData: MoodRankAnalytics = MoodRankAnalytics(
        moodRankDays: [
            MoodRankDaySummary(date: Date().addingTimeInterval(-7 * TimeInterval.day), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-6 * TimeInterval.day), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-5 * TimeInterval.day), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-4 * TimeInterval.day), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-3 * TimeInterval.day), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-2 * TimeInterval.day), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-TimeInterval.day), averageMoodRankValue: nil)
        ]
    )
    
    static var previews: some View {
        Group {
            PastWeekMoodChartView(viewModel: PastWeekMoodChartView.ViewModel(analytics: pastWeekWithData))
                .frame(width: 500, height: 300)
                .previewLayout(.sizeThatFits)
            
            
            PastWeekMoodChartView(viewModel: PastWeekMoodChartView.ViewModel(analytics: pastWeekWithNoData))
                .frame(width: 500, height: 300)
                .previewLayout(.sizeThatFits)
        }
    }
}
