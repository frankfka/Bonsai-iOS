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
        var isDateIncrementDisabled: Bool {
            // Date selection is today or later
            let selectedDate = dateSelectionBinding.wrappedValue
            return selectedDate > Date().beginningOfDate
        }
        
        init(confirmedDate: Date, dateSelectionBinding: Binding<Date>, onNewDateConfirmed: DateCallback? = nil) {
            self.dateSelectionBinding = dateSelectionBinding
            self.confirmedDate = confirmedDate
            self.onNewDateConfirmed = onNewDateConfirmed
        }
    }
    @State var showDatePicker: Bool = false
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Child views
    private var cancelDateSelectionButton: some View {
        // Left cancel button - show only when date picker is shown
        Button(action: {
            self.onDateSelectionCancel()
        }) {
            Text("Cancel")
                .font(Font.Theme.NormalText)
                .foregroundColor(Color.Theme.Primary)
        }
    }
    private var decrementDateButton: some View {
        // Left chevron - to decrement date
        Button(action: {
            self.onDecrementDateTapped()
        }) {
            Image.Icons.ChevronLeft
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CGFloat.Theme.Font.NormalIcon, height: CGFloat.Theme.Font.NormalIcon)
                .foregroundColor(Color.Theme.Primary)
        }
    }
    private var leftBarButton: some View {
        Group {
            if showDatePicker {
                self.cancelDateSelectionButton
            } else {
                self.decrementDateButton
            }
        }
        .padding(CGFloat.Theme.Layout.Small)
    }

    private var barCenterDateDisplayView: some View {
        // Center date display
        HStack(spacing: 0) {
            Text(DateFormatter.stringForLogDatePicker(from: self.viewModel.dateSelectionBinding.wrappedValue))
                .font(Font.Theme.NormalBoldText)
                .foregroundColor(Color.Theme.Text)
                .padding(.trailing, CGFloat.Theme.Layout.Small)
            (showDatePicker ? Image.Icons.ChevronDown : Image.Icons.ChevronRight)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CGFloat.Theme.Font.SmallIcon, height: CGFloat.Theme.Font.SmallIcon)
                .foregroundColor(Color.Theme.Text)
        }
    }

    private var confirmDateSelectionButton: some View {
        // Right confirmation button - show only when date picker is shown
        Button(action: {
            self.onDateSelectionConfirmed()
        }) {
            Text("Done")
                .font(Font.Theme.NormalBoldText)
                .foregroundColor(Color.Theme.Primary)
        }
    }
    private var incrementDateButton: some View {
        // Right chevron - to increment date
        Button(action: {
            self.onIncrementDateTapped()
        }) {
            Image.Icons.ChevronRight
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CGFloat.Theme.Font.NormalIcon, height: CGFloat.Theme.Font.NormalIcon)
                .foregroundColor(viewModel.isDateIncrementDisabled ? Color.Theme.GrayscalePrimary : Color.Theme.Primary)
        }
        .disabled(viewModel.isDateIncrementDisabled)
    }
    private var rightBarButton: some View {
        Group {
            if showDatePicker {
                self.confirmDateSelectionButton
            } else {
                self.incrementDateButton
            }
        }
        .padding(CGFloat.Theme.Layout.Small)
    }

    private var topBarView: some View {
        HStack {
            self.leftBarButton
            Spacer()
            self.barCenterDateDisplayView
            Spacer()
            self.rightBarButton
        }
        .padding(.vertical, CGFloat.Theme.Layout.Small)
        .padding(.horizontal, CGFloat.Theme.Layout.Normal)
        .contentShape(Rectangle())
        .onTapGesture {
            self.onDateViewTapped()
        }
    }

    // MARK: Main body
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            // Top Bar view
            self.topBarView
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
        // TODO: Modifying state during view update, look into this
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
