//
//  LogReminderIntervalPickerView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-07.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogReminderIntervalPickerView: View {
    
    struct ViewModel {
        static let intervalValueSelection: [(strValue: String, val: Int)] = Array(1...24).map {
            ("\($0)", $0)
        }
        static let intervalTypeSelection: [(strValue: String, pluralStrValue: String, val: TimeInterval)] = [
            ("Hour", "Hours", TimeInterval.hour),
            ("Day", "Days", TimeInterval.day),
            ("Week", "Weeks", TimeInterval.week)
        ]
        static func intervalToSelection(_ interval: TimeInterval) -> (valueIdx: Int, typeIdx: Int) {
            // This will always return the biggest time interval (something saved as 7 days -> 1 week after reload)
            let valueIdx: Int?
            let typeIdx: Int?
            if interval.truncatingRemainder(dividingBy: TimeInterval.week) == 0 {
                valueIdx = intervalValueSelection.firstIndex { _, val in val == Int(interval / TimeInterval.week) }
                typeIdx = intervalTypeSelection.firstIndex { _, _, timeInterval in timeInterval == TimeInterval.week }
            } else if interval.truncatingRemainder(dividingBy: TimeInterval.day) == 0 {
                valueIdx = intervalValueSelection.firstIndex { _, val in val == Int(interval / TimeInterval.day) }
                typeIdx = intervalTypeSelection.firstIndex { _, _, timeInterval in timeInterval == TimeInterval.day }
            } else {
                valueIdx = intervalValueSelection.firstIndex { _, val in val == Int(interval / TimeInterval.hour) }
                typeIdx = intervalTypeSelection.firstIndex { _, _, timeInterval in timeInterval == TimeInterval.hour }
            }
            if let valueIdx = valueIdx, let typeIdx = typeIdx {
                return (valueIdx, typeIdx)
            }
            // Default to first selection
            AppLogging.warn("Could not convert time interval \(interval) to picker selection")
            return (0, 0)
        }
        static func selectionToInterval(_ selection: (valueIdx: Int, typeIdx: Int)) -> TimeInterval {
            guard selection.valueIdx < ViewModel.intervalValueSelection.count
                          && selection.typeIdx < ViewModel.intervalTypeSelection.count else {
                AppLogging.warn("Selection out of bounds!")
                return .week
            }
            let selectedValue = ViewModel.intervalValueSelection[selection.valueIdx].val
            let selectedType = ViewModel.intervalTypeSelection[selection.typeIdx].val
            return TimeInterval(selectedType * Double(selectedValue))
        }

        @Binding var showPicker: Bool
        let valuePickerSelection: Binding<Int>
        let typePickerSelection: Binding<Int>
        var rowDisplay: String {
            let selectedValue = ViewModel.intervalValueSelection[valuePickerSelection.wrappedValue].val
            let selectedValueStr = ViewModel.intervalValueSelection[valuePickerSelection.wrappedValue].strValue
            let selectedTypeStr: String
            if selectedValue > 1 {
                selectedTypeStr = ViewModel.intervalTypeSelection[typePickerSelection.wrappedValue].pluralStrValue
            } else {
                selectedTypeStr = ViewModel.intervalTypeSelection[typePickerSelection.wrappedValue].strValue
            }
            return "\(selectedValueStr) \(selectedTypeStr)"
        }
        
        init(selectedInterval: TimeInterval, showPicker: Binding<Bool>, onIntervalSelect: TimeIntervalCallback? = nil) {
            let initialSelection = ViewModel.intervalToSelection(selectedInterval)
            self.valuePickerSelection = Binding(get: {
                initialSelection.valueIdx
            }, set: { (newValueSelection) in
                if newValueSelection != initialSelection.valueIdx {
                    onIntervalSelect?(ViewModel.selectionToInterval((newValueSelection, initialSelection.typeIdx)))
                }
            })
            self.typePickerSelection = Binding(get: {
                initialSelection.typeIdx
            }, set: { (newTypeSelection) in
                if newTypeSelection != initialSelection.typeIdx {
                    onIntervalSelect?(ViewModel.selectionToInterval((initialSelection.valueIdx, newTypeSelection)))
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
                            ForEach(0..<ViewModel.intervalValueSelection.count) { index in
                                Text(ViewModel.intervalValueSelection[index].0)
                                        .tag(index)
                                        .font(Font.Theme.normalText)
                                        .foregroundColor(Color.Theme.textDark)
                            }
                        }
                        // For type selection
                        Picker(
                            selection: self.viewModel.typePickerSelection,
                            label: Text("")
                        ) {
                            ForEach(0..<ViewModel.intervalTypeSelection.count) { index in
                                Text(ViewModel.intervalTypeSelection[index].0)
                                        .tag(index)
                                        .font(Font.Theme.normalText)
                                        .foregroundColor(Color.Theme.textDark)
                            }
                        }
                    }
                    .labelsHidden()
                    .padding(CGFloat.Theme.Layout.small)
                    .frame(maxWidth: parentGeometry.size.width / 2)
                    .clipped()
                }
                .frame(maxWidth: parentGeometry.size.width * 0.95)
                .clipped()
            }
        }
        .background(Color.Theme.backgroundSecondary)
    }
    
    private func getRowViewModel() -> TappableRowView.ViewModel {
        return TappableRowView.ViewModel(
            primaryText: .constant("Repeat Every"),
            secondaryText: .constant(self.viewModel.rowDisplay),
            hasDisclosureIndicator: false
        )
    }
    
    private func rowTapped() {
        ViewHelpers.toggleWithAnimation(binding: self.viewModel.$showPicker)
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
