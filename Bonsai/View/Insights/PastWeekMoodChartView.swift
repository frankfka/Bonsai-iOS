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

struct MoodRankDaySummary {
    let date: Date
    let averageMoodRankValue: Double? // Nil if none exist for that date
}

struct MoodRankAnalytics {
    let moodRankDays: [MoodRankDaySummary]
    var averageMoodRankValue: Double? {
        let values = moodRankDays.compactMap {
            $0.averageMoodRankValue
        }
        let numValues = values.count
        if numValues == 0 {
            return nil
        }
        return values.reduce(0.0, +) / Double(numValues)
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
        static let lineChartStyle = LineChartStyle(
            lineColor: Color.Theme.accent.opacity(0.8),
            lineStrokeStyle: StrokeStyle(lineWidth: CGFloat.Theme.Charts.lineWidth),
            smoothed: false
        )
        
        let axisLabels: [String]
        let barChartData: [BarChartDataPoint]
        let lineChartData: LineChartData
        
        init(analytics: MoodRankAnalytics) {
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
        }
        
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
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
    
    static var pastWeekData: MoodRankAnalytics = MoodRankAnalytics(
        moodRankDays: [
            MoodRankDaySummary(date: Date().addingTimeInterval(-604800), averageMoodRankValue: positiveMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-518400), averageMoodRankValue: neutralMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-432000), averageMoodRankValue: negativeMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-345600), averageMoodRankValue: nil),
            MoodRankDaySummary(date: Date().addingTimeInterval(-259200), averageMoodRankValue: neutralMood),
            MoodRankDaySummary(date: Date().addingTimeInterval(-172800), averageMoodRankValue: (negativeMood + neutralMood) / 2.0),
            MoodRankDaySummary(date: Date().addingTimeInterval(-86400), averageMoodRankValue: negativeMood)
        ]
    )
    
    static var previews: some View {
        PastWeekMoodChartView(viewModel: PastWeekMoodChartView.ViewModel(analytics: pastWeekData))
            .frame(width: 500, height: 300)
            .previewLayout(.sizeThatFits)
    }
}
