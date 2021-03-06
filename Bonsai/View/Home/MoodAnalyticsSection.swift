//
//  MoodAnalyticsSection.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-01.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct MoodAnalyticsSection: View {
    
    struct ViewModel {
        let isLoading: Bool
        let loadError: Bool
        let chartViewModel: HistoricalMoodChartView.ViewModel?
        
        init(chartViewModel: HistoricalMoodChartView.ViewModel?, isLoading: Bool, loadError: Bool) {
            self.chartViewModel = chartViewModel
            self.isLoading = isLoading
            self.loadError = loadError
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if self.viewModel.isLoading {
                FullWidthLoadingSpinner(size: .small)
                    .frame(minHeight: CGFloat.Theme.Layout.MinSectionHeight)
            } else if self.viewModel.loadError {
                GenericErrorView()
            } else {
                self.viewModel.chartViewModel.map {
                    HistoricalMoodChartView(viewModel: $0)
                        .padding(CGFloat.Theme.Layout.Small)
                }
            }
        }
    }
}

struct MoodAnalyticsSection_Previews: PreviewProvider {

    private static var dataVm = MoodAnalyticsSection.ViewModel(
            chartViewModel: HistoricalMoodChartView.ViewModel(analytics: AnalyticsPreviews.HistoricalMoodPastWeekWithData),
            isLoading: false,
            loadError: false
    )

    private static var loadingVm = MoodAnalyticsSection.ViewModel(
            chartViewModel: nil,
            isLoading: true,
            loadError: false
    )

    private static var errorVm = MoodAnalyticsSection.ViewModel(
            chartViewModel: nil,
            isLoading: false,
            loadError: true
    )

    static var previews: some View {
        Group {
            MoodAnalyticsSection(viewModel: dataVm)
            MoodAnalyticsSection(viewModel: loadingVm)
            MoodAnalyticsSection(viewModel: errorVm)
        }
        .frame(maxHeight: 450)
        .previewLayout(.sizeThatFits)
    }
}
