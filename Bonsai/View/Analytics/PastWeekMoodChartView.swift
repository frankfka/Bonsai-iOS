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
            let buffer = (maxValue - minValue) * 0.2
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

    private static let minChartHeight: CGFloat = 200 // TODO: Somehow make this not a constant
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
                        .font(Font.Theme.subtext)
                        .foregroundColor(Color.Theme.text)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, ViewModel.barChartPadding)
        }.frame(minHeight: PastWeekMoodChartView.minChartHeight)
    }
}

struct PastWeekMoodChartView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            PastWeekMoodChartView(viewModel: PastWeekMoodChartView.ViewModel(analytics: AnalyticsPreviews.PastWeekWithData))
                .frame(width: 500, height: 300)
                .previewLayout(.sizeThatFits)
            
            
            PastWeekMoodChartView(viewModel: PastWeekMoodChartView.ViewModel(analytics: AnalyticsPreviews.PastWeekWithNoData))
                .frame(width: 500, height: 300)
                .previewLayout(.sizeThatFits)
        }
    }
}
