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
            } else if self.viewModel.loadError {
                ErrorView()
            } else {
                self.viewModel.chartViewModel.map {
                    PastWeekMoodChartView(viewModel: $0)
                }
            }
        }
        .frame(minHeight: 250) // TODO: Somehow get a dynamic height
    }
}

//struct MoodAnalyticsSection_Previews: PreviewProvider {
//    static var previews: some View {
//        MoodAnalyticsSection()
//    }
//}
