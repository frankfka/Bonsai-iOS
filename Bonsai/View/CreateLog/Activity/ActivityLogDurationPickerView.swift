//
//  ActivityLogDurationPickerView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2020-01-05.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct ActivityLogDurationPickerView: View {
    typealias DurationCallback = (TimeInterval) -> Void
    typealias DurationPickerValue = (String, Int) // String display value and integer value in seconds
    
    struct ViewModel {
        static let hourIncrement: Int = 1
        static let HourSelections: [DurationPickerValue]
            = stride(from: 0, through: 24, by: hourIncrement).map { (displayValue(for: $0), 3600 * $0) }
        static let minuteIncrement: Int = 5
        static let MinuteSelections: [DurationPickerValue]
            = stride(from: 0, through: 55, by: minuteIncrement).map { (displayValue(for: $0), 60 * $0) }
        
        let selectedHourIndex: Int
        let selectedMinuteIndex: Int
        private let onDurationChangeCallback: DurationCallback?
        
        init(duration: TimeInterval, onDurationChange: DurationCallback? = nil) {
            (self.selectedHourIndex, self.selectedMinuteIndex) = ViewModel.durationToIndices(duration)
            self.onDurationChangeCallback = onDurationChange
        }

        // Callbacks fired by picker changes
        func onHourIndexChange(newHourIndex: Int) {
            onDurationChange(hourIndex: newHourIndex, minuteIndex: selectedMinuteIndex)
        }

        func onMinuteIndexChange(newMinuteIndex: Int) {
            onDurationChange(hourIndex: selectedHourIndex, minuteIndex: newMinuteIndex)
        }

        // Calls VM callback with new values
        private func onDurationChange(hourIndex: Int, minuteIndex: Int) {
            let seconds = ViewModel.HourSelections[hourIndex].1 + ViewModel.MinuteSelections[minuteIndex].1
            self.onDurationChangeCallback?(TimeInterval(seconds))
        }
        
        static private func displayValue(for timeItem: Int) -> String {
            return "\(timeItem)"
        }
        
        static private func durationToIndices(_ duration: TimeInterval) -> (Int, Int) {
            var seconds = Int(duration.magnitude)
            let numHourIncrements: Int
            let numMinuteIncrements: Int
            (numHourIncrements, seconds) = seconds.quotientAndRemainder(dividingBy: 3600 * hourIncrement)
            (numMinuteIncrements, seconds) = seconds.quotientAndRemainder(dividingBy: 60 * minuteIncrement)
            // Remainder should be 0 here
            if seconds > 0 {
                AppLogging.warn("Conversion from duration to picker value resulted in a remainder: \(seconds)")
            }
            return (numHourIncrements, numMinuteIncrements)
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            DurationPickerWithLabelView(viewModel: self.getHourPickerViewModel())
            DurationPickerWithLabelView(viewModel: self.getMinutePickerViewModel())
        }
        .padding(CGFloat.Theme.Layout.Small)
    }

    private func getHourPickerViewModel() -> DurationPickerWithLabelView.ViewModel {
        return DurationPickerWithLabelView.ViewModel(
                values: ViewModel.HourSelections.map { $0.0 },
                label: "Hr",
                selectedIndex: self.viewModel.selectedHourIndex,
                onSelectionChange: self.viewModel.onHourIndexChange
        )
    }

    private func getMinutePickerViewModel() -> DurationPickerWithLabelView.ViewModel {
        return DurationPickerWithLabelView.ViewModel(
                values: ViewModel.MinuteSelections.map { $0.0 },
                label: "Min",
                selectedIndex: self.viewModel.selectedMinuteIndex,
                onSelectionChange: self.viewModel.onMinuteIndexChange
        )
    }

}

struct DurationPickerWithLabelView: View {
    
    struct ViewModel {
        let values: [String]
        let label: String
        @Binding var selectedIndex: Int
        
        init(values: [String], label: String, selectedIndex: Int, onSelectionChange: IntCallback? = nil) {
            self.values = values
            self.label = label
            self._selectedIndex = Binding(get: {
                selectedIndex
            }, set: { newVal in
                onSelectionChange?(newVal)
            })
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Picker(
                selection: self.viewModel.$selectedIndex,
                label: Text("")
            ) {
                ForEach(0 ..< self.viewModel.values.count) {
                    Text(self.viewModel.values[$0])
                        .tag($0)
                        .font(Font.Theme.NormalText)
                        .foregroundColor(Color.Theme.Text)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(minWidth: 50, maxWidth: .infinity)
            .labelsHidden()
            .clipped()
            Text(self.viewModel.label)
                .padding(.horizontal, CGFloat.Theme.Layout.Small)
        }
    }
    
}

struct ActivityLogDurationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityLogDurationPickerView(
            viewModel: ActivityLogDurationPickerView.ViewModel(duration: TimeInterval(300))
        )
        .previewLayout(.sizeThatFits)
    }
}
