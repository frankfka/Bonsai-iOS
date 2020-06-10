//
//  LogReminderIntervalPickerView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-07.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// TODO: There's some weird behavior with 24 hours automatically converting to 1 day, but not a big deal
extension TimeInterval {
    static let reminderIntervalValueSelections: [(strValue: String, val: Int)] = Array(1...24).map {
        ("\($0)", $0)
    }
    static let reminderIntervalTypeSelections: [(strValue: String, pluralStrValue: String, val: TimeInterval)] = [
        ("Hour", "Hours", TimeInterval.hour),
        ("Day", "Days", TimeInterval.day),
        ("Week", "Weeks", TimeInterval.week)
    ]
    static func reminderIntervalToSelection(_ interval: TimeInterval) -> (valueIdx: Int, typeIdx: Int) {
        // This will always return the biggest time interval (something saved as 7 days -> 1 week after reload)
        if let (num, interval) = interval.reduceToSingleComponent(),
           let valueIdx = reminderIntervalValueSelections.firstIndex(where: { _, val in val == num }),
           let typeIdx = reminderIntervalTypeSelections.firstIndex(where: { _, _, timeInterval in timeInterval == interval }) {
            return (valueIdx, typeIdx)
        }
        // Default to first selection
        AppLogging.warn("Could not convert time interval \(interval) to picker selection")
        return (0, 0)
    }
    static func reminderSelectionToInterval(_ selection: (valueIdx: Int, typeIdx: Int)) -> TimeInterval {
        guard selection.valueIdx < reminderIntervalValueSelections.count
                      && selection.typeIdx < reminderIntervalTypeSelections.count else {
            AppLogging.warn("Selection out of bounds!")
            return .week
        }
        let selectedValue = reminderIntervalValueSelections[selection.valueIdx].val
        let selectedType = reminderIntervalTypeSelections[selection.typeIdx].val
        return TimeInterval(selectedType * Double(selectedValue))
    }
}

struct LogReminderIntervalPickerView: View {
    
    struct ViewModel {
        static let intervalValueSelections = TimeInterval.reminderIntervalValueSelections
        static let intervalTypeSelections = TimeInterval.reminderIntervalTypeSelections
        @Binding var showPicker: Bool
        let valuePickerSelection: Binding<Int>
        let typePickerSelection: Binding<Int>
        var rowDisplay: String {
            let selectedValue = TimeInterval.reminderIntervalValueSelections[valuePickerSelection.wrappedValue].val
            let selectedValueStr = TimeInterval.reminderIntervalValueSelections[valuePickerSelection.wrappedValue].strValue
            let selectedTypeStr: String
            if selectedValue > 1 {
                selectedTypeStr = TimeInterval.reminderIntervalTypeSelections[typePickerSelection.wrappedValue].pluralStrValue
            } else {
                selectedTypeStr = TimeInterval.reminderIntervalTypeSelections[typePickerSelection.wrappedValue].strValue
            }
            return "\(selectedValueStr) \(selectedTypeStr)"
        }
        
        init(selectedInterval: TimeInterval, showPicker: Binding<Bool>, onIntervalSelect: TimeIntervalCallback? = nil) {
            let initialSelection = TimeInterval.reminderIntervalToSelection(selectedInterval)
            self.valuePickerSelection = Binding(get: {
                initialSelection.valueIdx
            }, set: { (newValueSelection) in
                if newValueSelection != initialSelection.valueIdx {
                    onIntervalSelect?(TimeInterval.reminderSelectionToInterval((newValueSelection, initialSelection.typeIdx)))
                }
            })
            self.typePickerSelection = Binding(get: {
                initialSelection.typeIdx
            }, set: { (newTypeSelection) in
                if newTypeSelection != initialSelection.typeIdx {
                    onIntervalSelect?(TimeInterval.reminderSelectionToInterval((initialSelection.valueIdx, newTypeSelection)))
                }
            })
            self._showPicker = showPicker
        }
    }
    
    private let viewModel: ViewModel
    private let parentGeometry: GeometryProxy
    
    init(viewModel: ViewModel, geometry: GeometryProxy) {
        self.viewModel = viewModel
        self.parentGeometry = geometry
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TappableRowView(viewModel: self.getRowViewModel())
                .onTapGesture {
                    self.rowTapped()
                }
            if self.viewModel.showPicker {
                HStack {
                    Group {
                        // For value selection
                        Picker(
                            selection: self.viewModel.valuePickerSelection,
                            label: Text("")
                        ) {
                            ForEach(0..<ViewModel.intervalValueSelections.count) { index in
                                Text(ViewModel.intervalValueSelections[index].0)
                                        .tag(index)
                                        .font(Font.Theme.NormalText)
                                        .foregroundColor(Color.Theme.Text)
                            }
                        }
                        // For type selection
                        Picker(
                            selection: self.viewModel.typePickerSelection,
                            label: Text("")
                        ) {
                            ForEach(0..<ViewModel.intervalTypeSelections.count) { index in
                                Text(ViewModel.intervalTypeSelections[index].0)
                                        .tag(index)
                                        .font(Font.Theme.NormalText)
                                        .foregroundColor(Color.Theme.Text)
                            }
                        }
                    }
                    .labelsHidden()
                    .padding(CGFloat.Theme.Layout.Small)
                    .frame(maxWidth: parentGeometry.size.width / 2)
                    .clipped()
                }
                .frame(maxWidth: parentGeometry.size.width * 0.95)
                .clipped()
            }
        }
        .background(Color.Theme.BackgroundSecondary)
    }
    
    private func getRowViewModel() -> TappableRowView.ViewModel {
        return TappableRowView.ViewModel(
            primaryText: .constant("Repeat Every"),
            secondaryText: .constant(self.viewModel.rowDisplay),
            hasDisclosureIndicator: false
        )
    }
    
    private func rowTapped() {
        ViewHelpers.toggleWithEaseAnimation(binding: self.viewModel.$showPicker)
    }
    
}

struct LogReminderIntervalPickerView_Previews: PreviewProvider {
    
    private static let viewModel = LogReminderIntervalPickerView.ViewModel(
            selectedInterval: .week,
            showPicker: .constant(true)
    )
    
    static var previews: some View {
        GeometryReader { geometry in
            LogReminderIntervalPickerView(viewModel: viewModel, geometry: geometry)
        }
        .previewLayout(.sizeThatFits)
    }
}
