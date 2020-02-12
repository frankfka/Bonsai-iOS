//
//  CreateLogDateView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-02-11.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // Date, time shown in create log view rows
    private static var createLogDateOnlyFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }
    private static var createLogTimeOnlyFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }
    
    static func stringForCreateLogDate(from date: Date) -> String {
        return createLogDateOnlyFormatter.string(from: date)
    }
    static func stringForCreateLogTime(from date: Date) -> String {
        return createLogTimeOnlyFormatter.string(from: date)
    }
}


struct CreateLogDateView: View {
    
    struct ViewModel {
        @Binding var selectedDate: Date
        @Binding var showDatePicker: Bool
        @Binding var showTimePicker: Bool
        var dateString: String {
            DateFormatter.stringForCreateLogDate(from: selectedDate)
        }
        var timeString: String {
            DateFormatter.stringForCreateLogTime(from: selectedDate)
        }
        
        init(selectedDate: Date, showDatePicker: Binding<Bool>, showTimePicker: Binding<Bool>, onDateChange: DateCallback? = nil) {
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
                DatePicker(
                    selection: self.viewModel.$selectedDate,
                    in: ...Date(),
                    displayedComponents: .date) {
                        Text("")
                }
                .labelsHidden()
            }
            Divider()
            // Time Selection
            TappableRowView(viewModel: getLogTimeRowViewModel())
                .onTapGesture {
                    self.timePickerRowTapped()
            }
            if viewModel.showTimePicker {
                DatePicker(
                    selection: self.viewModel.$selectedDate,
                    in: ...Date(),
                    displayedComponents: .hourAndMinute) {
                        Text("")
                }
                .labelsHidden()
                .font(Font.Theme.normalText)
                .foregroundColor(Color.Theme.textDark)
            }
        }
        .background(Color.Theme.backgroundSecondary)
    }
    
    // Actions
    private func datePickerRowTapped() {
        ViewHelpers.toggleWithAnimation(binding: viewModel.$showDatePicker)
    }
    
    private func timePickerRowTapped() {
        ViewHelpers.toggleWithAnimation(binding: viewModel.$showTimePicker)
    }
    
    // View models
    private func getLogDateRowViewModel() -> TappableRowView.ViewModel {
        return TappableRowView.ViewModel(
            primaryText: .constant("Date"),
            secondaryText: .constant(viewModel.dateString),
            hasDisclosureIndicator: false
        )
    }
    
    private func getLogTimeRowViewModel() -> TappableRowView.ViewModel {
        return TappableRowView.ViewModel(
            primaryText: .constant("Time"),
            secondaryText: .constant(viewModel.timeString),
            hasDisclosureIndicator: false
        )
    }
    
}

struct CreateLogDateView_Previews: PreviewProvider {
    
    private static let viewModel: CreateLogDateView.ViewModel = CreateLogDateView.ViewModel(
        selectedDate: Date(),
        showDatePicker: .constant(false),
        showTimePicker: .constant(false)
    )
    
    static var previews: some View {
        CreateLogDateView(viewModel: viewModel)
    }
}
