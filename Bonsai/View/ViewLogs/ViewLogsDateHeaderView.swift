//
//  ViewLogsDateHeaderView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2020-01-08.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // For date selection
    private static var logDatePickerFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyy"
        return formatter
    }
    static func stringForLogDatePicker(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        return logDatePickerFormatter.string(from: date)
    }
}

struct ViewLogsDateHeaderView: View {
    
    struct ViewModel {
        let confirmedDate: Date
        let dateSelectionBinding: Binding<Date> // This changes when user changes the date picker, but hasn't yet confirmed the date
        let onNewDateConfirmed: DateCallback?
        
        init(confirmedDate: Date, dateSelectionBinding: Binding<Date>, onNewDateConfirmed: DateCallback? = nil) {
            self.dateSelectionBinding = dateSelectionBinding
            self.confirmedDate = confirmedDate
            self.onNewDateConfirmed = onNewDateConfirmed
        }
        
        // Slightly hacky way to interface with a @state variable
        func isDateIncrementDisabled(selectedDate: Date) -> Bool {
            // Date selection is today or it is later than the current time
            return Calendar.current.isDateInToday(selectedDate) || selectedDate > Date()
        }
    }
    @State var showDatePicker: Bool = false
    private var isDateIncrementDisabled: Bool {
        viewModel.isDateIncrementDisabled(selectedDate: self.viewModel.dateSelectionBinding.wrappedValue)
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            // Top Bar view
            HStack {
                // Left bar item
                Group {
                    if showDatePicker {
                        // Left cancel button - show only when date picker is shown
                        Button(action: {
                            self.onDateSelectionCancel()
                        }) {
                            Text("Cancel")
                                .font(Font.Theme.NormalText)
                                .foregroundColor(Color.Theme.Primary)
                        }
                    } else {
                        // Left chevron - to decrement date
                        Button(action: {
                            self.onDecrementDateTapped()
                        }) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: CGFloat.Theme.Font.NormalIcon, height: CGFloat.Theme.Font.NormalIcon)
                                .foregroundColor(Color.Theme.Primary)
                        }
                    }
                }
                .padding(CGFloat.Theme.Layout.Small)
                Spacer()
                // Center date display
                HStack(spacing: 0) {
                    Text(DateFormatter.stringForLogDatePicker(from: self.viewModel.dateSelectionBinding.wrappedValue))
                        .font(Font.Theme.NormalBoldText)
                        .foregroundColor(Color.Theme.Text)
                        .padding(.trailing, CGFloat.Theme.Layout.Small)
                    Image(systemName: showDatePicker ? "chevron.down" : "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: CGFloat.Theme.Font.SmallIcon, height: CGFloat.Theme.Font.SmallIcon)
                        .foregroundColor(Color.Theme.Text)
                }
                Spacer()
                // Right bar item
                Group {
                    if showDatePicker {
                        // Right confirmation button - show only when date picker is shown
                        Button(action: {
                            self.onDateSelectionConfirmed()
                        }) {
                            Text("Done")
                                .font(Font.Theme.NormalBoldText)
                                .foregroundColor(Color.Theme.Primary)
                        }
                    } else {
                        // Right chevron - to increment date
                        Button(action: {
                            self.onIncrementDateTapped()
                        }) {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: CGFloat.Theme.Font.NormalIcon, height: CGFloat.Theme.Font.NormalIcon)
                                .foregroundColor(isDateIncrementDisabled ? Color.Theme.GrayscalePrimary : Color.Theme.Primary)
                        }
                        .disabled(isDateIncrementDisabled)
                    }
                }
                .padding(CGFloat.Theme.Layout.Small)
            }
            .padding(.vertical, CGFloat.Theme.Layout.Small)
            .padding(.horizontal, CGFloat.Theme.Layout.Normal)
            .contentShape(Rectangle())
            .onTapGesture {
                self.onDateViewTapped()
            }
            // Calendar Picker View
            if showDatePicker {
                DatePickerView(viewModel: getDatePickerViewModel())
            }
            Divider()
        }
        .onAppear(perform: {
            self.onViewAppear()
        })
        .background(Color.Theme.BackgroundSecondary)
    }
    
    private func getDatePickerViewModel() -> DatePickerView.ViewModel {
        return DatePickerView.ViewModel(selectedDate: self.viewModel.dateSelectionBinding)
    }
    
    private func onDecrementDateTapped() {
        let decrementedDate = self.viewModel.dateSelectionBinding.wrappedValue.addingTimeInterval(-TimeInterval.day)
        // Binding is a @State var so it doesn't update, so manually update it
        self.viewModel.dateSelectionBinding.wrappedValue = decrementedDate
        viewModel.onNewDateConfirmed?(decrementedDate)
    }
    
    private func onIncrementDateTapped() {
        let incrementedDate = self.viewModel.dateSelectionBinding.wrappedValue.addingTimeInterval(TimeInterval.day)
        if incrementedDate <= Date() {
            // Binding is a @State var so it doesn't update, so manually update it
            self.viewModel.dateSelectionBinding.wrappedValue = incrementedDate
            viewModel.onNewDateConfirmed?(incrementedDate)
        }
    }
    
    private func onDateViewTapped() {
        // Cancel current selection
        resetDateSelection()
        toggleDatePickerVisibility()
    }
    
    private func onDateSelectionConfirmed() {
        viewModel.onNewDateConfirmed?(self.viewModel.dateSelectionBinding.wrappedValue)
        toggleDatePickerVisibility()
    }
    
    private func onDateSelectionCancel() {
        // Cancel current selection
        resetDateSelection()
        toggleDatePickerVisibility()
    }
    
    private func toggleDatePickerVisibility() {
        ViewHelpers.toggleWithEaseAnimation(binding: $showDatePicker)
    }
    
    private func onViewAppear() {
        // Update selected date to current date
        resetDateSelection()
    }

    func resetDateSelection() {
        self.viewModel.dateSelectionBinding.wrappedValue = self.viewModel.confirmedDate
    }
    
}

struct ViewLogsDateHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ViewLogsDateHeaderView(
            viewModel: ViewLogsDateHeaderView.ViewModel(
                confirmedDate: Date(),
                dateSelectionBinding: .constant(Date())
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
