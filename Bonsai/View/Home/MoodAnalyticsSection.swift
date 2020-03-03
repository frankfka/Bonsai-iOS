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
        let chartViewModel: PastWeekMoodChartView.ViewModel?
        
        init(chartViewModel: PastWeekMoodChartView.ViewModel?, isLoading: Bool, loadError: Bool) {
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
                    .frame(minHeight: CGFloat.Theme.Layout.minSectionHeight)
            } else if self.viewModel.loadError {
                ErrorView()
            } else {
                self.viewModel.chartViewModel.map {
                    PastWeekMoodChartView(viewModel: $0)
                }
            }
        }
    }
}

struct MoodAnalyticsSection_Previews: PreviewProvider {

    private static var dataVm = MoodAnalyticsSection.ViewModel(
            chartViewModel: PastWeekMoodChartView.ViewModel(analytics: AnalyticsPreviews.PastWeekWithData),
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
