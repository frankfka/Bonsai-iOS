//
//  AnalyticsSettingsSection.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-22.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI
import Combine

struct AnalyticsSettingsSection: View {
    @EnvironmentObject var store: AppStore

    struct MoodRankDayPickerValue: RowPickerValue {
        static let values = (5...12).map { MoodRankDayPickerValue(dayValue: $0) }
        let dayValue: Int
        var pickerDisplay: String {
            "\(dayValue) Days"
        }
    }

    struct ViewModel {
        var analyticsMoodRankDays: Int {
            currentSettings.analyticsMoodRankDays
        }
        let currentSettings: User.Settings
        let onSettingsChanged: SettingsChangedCallback?

        init(settings: User.Settings, onSettingsChanged: SettingsChangedCallback? = nil) {
            self.currentSettings = settings
            self.onSettingsChanged = onSettingsChanged
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            RowPickerView(viewModel: getMoodRankDaysPickerViewModel())
        }
    }

    // View Models
    private func getMoodRankDaysPickerViewModel() -> RowPickerView.ViewModel {
        let selectedIndex = MoodRankDayPickerValue.values
                .firstIndex { $0.dayValue == viewModel.analyticsMoodRankDays } ?? 0
        let rowValue = MoodRankDayPickerValue.values[selectedIndex].pickerDisplay
        let selectionIndexBinding = Binding<Int>(get: {
            return selectedIndex
        }, set: { newVal in
            var newSettings = self.viewModel.currentSettings
            newSettings.analyticsMoodRankDays = MoodRankDayPickerValue.values[newVal].dayValue
            self.viewModel.onSettingsChanged?(newSettings)
        })
        return RowPickerView.ViewModel(
            rowTitle: "Mood Rank Days",
            rowValue: rowValue,
            values: MoodRankDayPickerValue.values,
            selectionIndex: selectionIndexBinding
        )
    }

}

struct AnalyticsSettingsSection_Previews: PreviewProvider {

    static let viewModel = AnalyticsSettingsSection.ViewModel(settings: User.Settings())

    static var previews: some View {
        AnalyticsSettingsSection(viewModel: viewModel)
            .environmentObject(PreviewRedux.filledStore)
            .previewLayout(.sizeThatFits)
    }
}
