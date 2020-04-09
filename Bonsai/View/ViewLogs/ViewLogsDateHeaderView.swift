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
        let initialDate: Date
        let onNewDateConfirmed: DateCallback?
        
        init(initialDate: Date, onNewDateConfirmed: DateCallback? = nil) {
            self.initialDate = initialDate
            self.onNewDateConfirmed = onNewDateConfirmed
        }
        
        // Slightly hacky way to interface with a @state variable
        func isDateIncrementDisabled(selectedDate: Date) -> Bool {
            // Date selection is today or it is later than the current time
            return Calendar.current.isDateInToday(selectedDate) || selectedDate > Date()
        }
    }
    @State var showDatePicker: Bool = false
    @State var selectedDate: Date = Date()
    private var isDateIncrementDisabled: Bool {
        viewModel.isDateIncrementDisabled(selectedDate: selectedDate)
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // TODO: Alignment guides to center
    // TODO: Today text, make it slide down instead of fade
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
                                .font(Font.Theme.normalText)
                                .foregroundColor(Color.Theme.primary)
                        }
                    } else {
                        // Left chevron - to decrement date
                        Button(action: {
                            self.onDecrementDateTapped()
                        }) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: CGFloat.Theme.Font.normalIcon, height: CGFloat.Theme.Font.normalIcon)
                                .foregroundColor(Color.Theme.primary)
                        }
                    }
                }
                .padding(CGFloat.Theme.Layout.small)
                Spacer()
                // Center date display
                HStack(spacing: 0) {
                    Text(DateFormatter.stringForLogDatePicker(from: selectedDate))
                        .font(Font.Theme.boldNormalText)
                        .foregroundColor(Color.Theme.textDark)
                        .padding(.trailing, CGFloat.Theme.Layout.small)
                    Image(systemName: showDatePicker ? "chevron.down" : "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: CGFloat.Theme.Font.smallIcon, height: CGFloat.Theme.Font.smallIcon)
                        .foregroundColor(Color.Theme.textDark)
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
                                .font(Font.Theme.boldNormalText)
                                .foregroundColor(Color.Theme.primary)
                        }
                    } else {
                        // Right chevron - to increment date
                        Button(action: {
                            self.onIncrementDateTapped()
                        }) {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: CGFloat.Theme.Font.normalIcon, height: CGFloat.Theme.Font.normalIcon)
                                .foregroundColor(isDateIncrementDisabled ? Color.Theme.grayscalePrimary : Color.Theme.primary)
                        }
                        .disabled(isDateIncrementDisabled)
                    }
                }
                .padding(CGFloat.Theme.Layout.small)
            }
            .padding(.vertical, CGFloat.Theme.Layout.small)
            .padding(.horizontal, CGFloat.Theme.Layout.normal)
            .contentShape(Rectangle())
            .onTapGesture {
                self.onDateViewTapped()
            }
            // Calendar Picker View
            if showDatePicker {
                // TODO: Top to bottom transition?
                DatePickerView(viewModel: getDatePickerViewModel())
            }
            Divider()
        }
        .onAppear(perform: {
            self.onViewAppear()
        })
        .background(Color.Theme.backgroundSecondary)
    }
    
    private func getDatePickerViewModel() -> DatePickerView.ViewModel {
        return DatePickerView.ViewModel(selectedDate: $selectedDate)
    }
    
    private func onDecrementDateTapped() {
        let decrementedDate = selectedDate.addingTimeInterval(-TimeInterval.day)
        // @State var doesn't update, so manually update it
        selectedDate = decrementedDate
        viewModel.onNewDateConfirmed?(decrementedDate)
    }
    
    private func onIncrementDateTapped() {
        let incrementedDate = selectedDate.addingTimeInterval(TimeInterval.day)
        if incrementedDate <= Date() {
            // @State var doesn't update, so manually update it
            selectedDate = incrementedDate
            viewModel.onNewDateConfirmed?(incrementedDate)
        }
    }
    
    private func onDateViewTapped() {
        // Cancel current selection
        setToInitialDate()
        toggleDatePickerVisibility()
    }
    
    private func onDateSelectionConfirmed() {
        viewModel.onNewDateConfirmed?(selectedDate)
        toggleDatePickerVisibility()
    }
    
    private func onDateSelectionCancel() {
        // Cancel current selection
        setToInitialDate()
        toggleDatePickerVisibility()
    }
    
    private func toggleDatePickerVisibility() {
        ViewHelpers.toggleWithAnimation(binding: $showDatePicker)
    }
    
    private func onViewAppear() {
        // Update selected date to current date
        setToInitialDate()
    }
    
    private func setToInitialDate() {
        selectedDate = viewModel.initialDate
    }
    
}

struct ViewLogsDateHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ViewLogsDateHeaderView(
            viewModel: ViewLogsDateHeaderView.ViewModel(initialDate: Date())
        )
            .previewLayout(.sizeThatFits)
    }
}
