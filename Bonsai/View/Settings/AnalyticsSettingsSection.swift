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

    // MARK: View model
    struct ViewModel {
        var analyticsMoodRankDays: Int {
            currentSettings.analyticsMoodRankDays
        }
        var analyticsSymptomSeverityDays: Int {
            currentSettings.analyticsSymptomSeverityDays
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

    // MARK: Child view models
    private var moodRankDaysPickerViewVm: RowPickerView.ViewModel {
        // Find currently selected index
        let selectedIndex = MoodRankDaysPickerValue.values
            .firstIndex { $0.dayValue == viewModel.analyticsMoodRankDays } ?? 0
        // Get the row display value
        let rowValue = MoodRankDaysPickerValue.values[selectedIndex].pickerDisplay
        // Create the binding
        let selectionIndexBinding = Binding<Int>(get: {
            return selectedIndex
        }, set: { newVal in
            // Mutate the settings, and call callback
            var newSettings = self.viewModel.currentSettings
            newSettings.analyticsMoodRankDays = MoodRankDaysPickerValue.values[newVal].dayValue
            self.viewModel.onSettingsChanged?(newSettings)
        })
        return RowPickerView.ViewModel(
            rowTitle: "Mood Rank Days",
            rowValue: rowValue,
            values: MoodRankDaysPickerValue.values,
            selectionIndex: selectionIndexBinding
        )
    }

    private var symptomSeverityDaysPickerViewVm: RowPickerView.ViewModel {
        // Find currently selected index
        let selectedIndex = SymptomSeverityDaysPickerValue.values
            .firstIndex { $0.dayValue == viewModel.analyticsSymptomSeverityDays } ?? 0
        // Get the row display value
        let rowValue = SymptomSeverityDaysPickerValue.values[selectedIndex].pickerDisplay
        // Create the binding
        let selectionIndexBinding = Binding<Int>(get: {
            return selectedIndex
        }, set: { newVal in
            // Mutate the settings, and call callback
            var newSettings = self.viewModel.currentSettings
            newSettings.analyticsSymptomSeverityDays = SymptomSeverityDaysPickerValue.values[newVal].dayValue
            self.viewModel.onSettingsChanged?(newSettings)
        })
        return RowPickerView.ViewModel(
            rowTitle: "Symptom Severity Days",
            rowValue: rowValue,
            values: SymptomSeverityDaysPickerValue.values,
            selectionIndex: selectionIndexBinding
        )
    }

    // MARK: Main Body
    var body: some View {
        VStack {
            RowPickerView(viewModel: self.moodRankDaysPickerViewVm)
            RowPickerView(viewModel: self.symptomSeverityDaysPickerViewVm)
        }
    }
}

// MARK: Additional models
extension AnalyticsSettingsSection {
    // Values for Mood Rank days
    struct MoodRankDaysPickerValue: RowPickerValue {
        static let values = (5...12).map { MoodRankDaysPickerValue(dayValue: $0) }
        let dayValue: Int
        var pickerDisplay: String {
            "\(dayValue) Days"
        }
    }
    // Values for Symptom Severity days
    struct SymptomSeverityDaysPickerValue: RowPickerValue {
        static let values = (5...12).map { SymptomSeverityDaysPickerValue(dayValue: $0) }
        let dayValue: Int
        var pickerDisplay: String {
            "\(dayValue) Days"
        }
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
