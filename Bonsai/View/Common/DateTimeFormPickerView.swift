//
//  DateTimeFormPickerView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-07.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI


extension DateFormatter {
    private static var datePickerDateOnlyFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyy"
        return dateFormatter
    }
    private static var datePickerTimeOnlyFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }
    
    static func stringForDatePickerDate(from date: Date) -> String {
        return datePickerDateOnlyFormatter.string(from: date)
    }
    static func stringForDatePickerTime(from date: Date) -> String {
        return datePickerTimeOnlyFormatter.string(from: date)
    }
}


struct DateTimeFormPickerView: View {

    struct ViewModel {
        @Binding var selectedDate: Date
        @Binding var showDatePicker: Bool
        @Binding var showTimePicker: Bool
        var dateString: String {
            DateFormatter.stringForDatePickerDate(from: selectedDate)
        }
        var timeString: String {
            DateFormatter.stringForDatePickerTime(from: selectedDate)
        }

        let datePickerLabel: String
        let timePickerLabel: String
        let isForwardLookingRange: Bool
        let rangeBoundDate: Date

        init(selectedDate: Date, showDatePicker: Binding<Bool>, showTimePicker: Binding<Bool>,
             isForwardLookingRange: Bool, rangeBoundDate: Date = Date(), datePickerLabel: String = "Date",
             timePickerLabel: String = "Time", onDateChange: DateCallback? = nil) {
            self._selectedDate = Binding<Date>(get: {
                return selectedDate
            }, set: { newDate in
                if newDate != selectedDate {
                    // Avoid calling callback if value didn't change
                    onDateChange?(newDate)
                }
            })
            self._showDatePicker = showDatePicker
            self._showTimePicker = showTimePicker
            self.isForwardLookingRange = isForwardLookingRange
            self.rangeBoundDate = rangeBoundDate
            self.datePickerLabel = datePickerLabel
            self.timePickerLabel = timePickerLabel
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Date Selection
            TappableRowView(viewModel: getLogDateRowViewModel())
                .onTapGesture {
                    self.datePickerRowTapped()
            }
            if viewModel.showDatePicker {
                getDatePicker(with: .date)
                    .labelsHidden()
            }
            Divider()
            // Time Selection
            TappableRowView(viewModel: getLogTimeRowViewModel())
                .onTapGesture {
                    self.timePickerRowTapped()
            }
            if viewModel.showTimePicker {
                getDatePicker(with: .hourAndMinute)
                    .labelsHidden()
            }
        }
        .background(Color.Theme.backgroundSecondary)
    }

    // Helper to get the correct Datepicker
    private func getDatePicker(with displayedComponents: DatePickerComponents) -> DatePicker<Text> {
        if viewModel.isForwardLookingRange {
            return DatePicker(
                    selection: self.viewModel.$selectedDate,
                    in: viewModel.rangeBoundDate...,
                    displayedComponents: displayedComponents
            ) {
                Text("")
            }
        } else {
            return DatePicker(
                    selection: self.viewModel.$selectedDate,
                    in: ...viewModel.rangeBoundDate,
                    displayedComponents: displayedComponents
            ) {
                Text("")
            }
        }
    }
    
    // Actions
    private func datePickerRowTapped() {
        ViewHelpers.toggleWithEaseAnimation(binding: viewModel.$showDatePicker)
    }
    
    private func timePickerRowTapped() {
        ViewHelpers.toggleWithEaseAnimation(binding: viewModel.$showTimePicker)
    }
    
    // View models
    private func getLogDateRowViewModel() -> TappableRowView.ViewModel {
        return TappableRowView.ViewModel(
            primaryText: .constant(viewModel.datePickerLabel),
            secondaryText: .constant(viewModel.dateString),
            hasDisclosureIndicator: false
        )
    }
    
    private func getLogTimeRowViewModel() -> TappableRowView.ViewModel {
        return TappableRowView.ViewModel(
            primaryText: .constant(viewModel.timePickerLabel),
            secondaryText: .constant(viewModel.timeString),
            hasDisclosureIndicator: false
        )
    }
}

struct DateTimeFormPickerView_Previews: PreviewProvider {
    
    private static let viewModel: DateTimeFormPickerView.ViewModel = DateTimeFormPickerView.ViewModel(
        selectedDate: Date(),
        showDatePicker: .constant(false),
        showTimePicker: .constant(false),
        isForwardLookingRange: false
    )
    
    static var previews: some View {
        DateTimeFormPickerView(viewModel: viewModel)
    }
}
