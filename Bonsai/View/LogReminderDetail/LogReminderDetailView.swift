//
//  LogReminderDetailView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-14.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // Full Date with day of week
    private static var logReminderDetailDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyy"
        return dateFormatter
    }
    // Time in 12hr (ex. 9:00AM)
    private static var logReminderDetailTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }
    static func stringForLogReminderDetailDate(from date: Date) -> String {
        return logReminderDetailDateFormatter.string(from: date)
    }
    static func stringForLogReminderDetailTime(from date: Date) -> String {
        return logReminderDetailTimeFormatter.string(from: date)
    }
}

struct LogReminderDetailView: View {

    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State(initialValue: false) private var showDeleteReminderConfirmation: Bool
    @State(initialValue: false) private var isPushNotificationEnabled: Bool
    
    struct ViewModel {
        // Default Log Reminder so we don't have nullables
        private static let EmptyLogReminder: LogReminder = LogReminder(
            id: "",
            reminderDate: Date(),
            reminderInterval: nil,
            templateLoggable: NoteLog(id: "", title: "", dateCreated: Date(),notes: "")
        )
        private static func getTimeIntervalString(_ interval: TimeInterval) -> String {
            let (valIdx, typeIdx) = TimeInterval.reminderIntervalToSelection(interval)
            let val = TimeInterval.reminderIntervalValueSelections[valIdx]
            let type = TimeInterval.reminderIntervalTypeSelections[typeIdx]
            let typeStr: String
            let valStr = val.strValue
            if val.val > 1 {
                typeStr = type.pluralStrValue
            } else {
                typeStr = type.strValue
            }
            return "\(valStr) \(typeStr)"
        }
        // State
        let isLoading: Bool
        let showDeleteSuccess: Bool
        let showDeleteError: Bool
        let showErrorView: Bool
        var disableActions: Bool {
            isLoading || showDeleteSuccess || showDeleteError
        }
        var disableDelete: Bool {
            // Don't allow deletes if we're loading or if there is no log reminder
            disableActions || logReminder.id.isEmptyWithoutWhitespace()
        }
        // Log reminder
        let logReminder: LogReminder
        let reminderDate: String
        let reminderTime: String
        let reminderInterval: String
        let showReminderInterval: Bool
        private let hasNotificationPermissions: Bool
        var showNoNotificationPermissionsText: Bool {
            !hasNotificationPermissions && isPushNotificationEnabled
        }
        let isPushNotificationEnabled: Bool
        let logTitle: String
        let logCategory: String


        init(state: AppState) {
            self.isLoading = state.logReminderDetails.isDeleting
            self.showDeleteSuccess = state.logReminderDetails.deleteSuccess
            self.showDeleteError = state.logReminderDetails.deleteError != nil
            self.showErrorView = state.logReminderDetails.logReminder == nil
            let logReminder = state.logReminderDetails.logReminder ?? ViewModel.EmptyLogReminder
            self.logReminder = logReminder
            self.reminderDate = DateFormatter.stringForLogReminderDetailDate(from: logReminder.reminderDate)
            self.reminderTime = DateFormatter.stringForLogReminderDetailTime(from: logReminder.reminderDate)
            self.logTitle = logReminder.templateLoggable.title
            self.logCategory = logReminder.templateLoggable.category.displayValue()
            if let interval = logReminder.reminderInterval {
                self.showReminderInterval = true
                self.reminderInterval = ViewModel.getTimeIntervalString(interval)
            } else {
                self.showReminderInterval = false
                self.reminderInterval = ""
            }
            self.isPushNotificationEnabled = state.logReminderDetails.isPushNotificationEnabled
            self.hasNotificationPermissions = state.global.hasNotificationPermissions
        }
    }
    // MARK: View models
    private var viewModel: ViewModel { ViewModel(state: store.state) }
    private var isPushNotificationEnabledRowVm: ToggleRowView.ViewModel {
        ToggleRowView.ViewModel(
            title: .constant("Push Notification"),
            description: self.viewModel.showNoNotificationPermissionsText ?
                .constant("Notifications permissions are currently disabled. Permissions must be enabled manually in iPhone settings.") :
                .constant(nil),
            value: Binding<Bool>(get: {
                self.isPushNotificationEnabled
            }, set: { newVal in
                self.isPushNotificationEnabledDidChange(isEnabled: newVal)
            })
        )
    }

    // MARK: Views

    // Main View
    var mainBody: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.Normal) {
                // Reminder Info
                TitledSection(sectionTitle: "Reminder Details") {
                    VStack(spacing: 0) {
                        TappableRowView(
                            viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Reminder Date"),
                                secondaryText: .constant(self.viewModel.reminderDate),
                                hasDisclosureIndicator: false
                            )
                        )
                        Divider()
                        TappableRowView(
                            viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Reminder Time"),
                                secondaryText: .constant(self.viewModel.reminderTime),
                                hasDisclosureIndicator: false
                            )
                        )
                        if self.viewModel.showReminderInterval {
                            Divider()
                            TappableRowView(
                                viewModel: TappableRowView.ViewModel(
                                    primaryText: .constant("Interval"),
                                    secondaryText: .constant(self.viewModel.reminderInterval),
                                    hasDisclosureIndicator: false
                                )
                            )
                        }
                        Divider()
                        ToggleRowView(viewModel: self.isPushNotificationEnabledRowVm)
                    }
                }
                // Loggable info
                TitledSection(sectionTitle: "Log Details") {
                    VStack(spacing: 0) {
                        TappableRowView(
                            viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Log"),
                                secondaryText: .constant(self.viewModel.logTitle),
                                hasDisclosureIndicator: false
                            )
                        )
                        Divider()
                        TappableRowView(
                            viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Category"),
                                secondaryText: .constant(self.viewModel.logCategory),
                                hasDisclosureIndicator: false
                            )
                        )
                    }
                }
            }
            .padding(.vertical, CGFloat.Theme.Layout.Normal)
        }
        .background(Color.Theme.BackgroundPrimary)
        .onReceive(self.store.$state, perform: { newState in
            // Update state vars to match that of store
            self.updateState(with: newState)
        })
    }

    // View with Error View
    var body: some View {
        VStack {
            if viewModel.showErrorView {
                ErrorView()
            } else {
                mainBody
            }
        }
        .navigationBarItems(
            trailing: Button(action: {
                self.onDeleteReminderTapped()
            }, label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: CGFloat.Theme.Layout.NavBarItemHeight)
                    .foregroundColor(
                        self.viewModel.disableDelete ?
                            Color.Theme.GrayscalePrimary : Color.Theme.Primary
                    )
            })
            .disabled(self.viewModel.disableDelete)
        )
        .navigationBarTitle("Reminder Details", displayMode: .inline)
        // Delete Reminder Confirmation
        .alert(isPresented: $showDeleteReminderConfirmation) {
            Alert(
                title: Text("Delete Reminder"),
                message: Text("Are you sure you want to delete this reminder?"),
                primaryButton: .destructive(
                    Text("Confirm"),
                    action: {
                        self.onDeleteReminderConfirmed()
                    }),
                secondaryButton: .cancel(
                    Text("Cancel")
                )
            )
        }
        // Popups
        .withLoadingPopup(show: .constant(self.viewModel.isLoading), text: "Deleting")
        .withStandardPopup(show: .constant(self.viewModel.showDeleteError), type: .failure, text: "Something Went Wrong") {
            self.onErrorPopupDismiss()
        }
        .withStandardPopup(show: .constant(self.viewModel.showDeleteSuccess), type: .success, text: "Deleted Successfully") {
            self.onDeleteSuccessPopupDismiss()
        }
    }

    // MARK: Actions
    private func isPushNotificationEnabledDidChange(isEnabled: Bool) {
        store.send(.logReminderDetails(action: .isPushNotificationEnabledDidChange(isEnabled: isEnabled)))
    }

    private func onDeleteReminderTapped() {
        showDeleteReminderConfirmation.toggle()
    }

    private func onDeleteReminderConfirmed() {
        store.send(.logReminderDetails(action: .deleteCurrentReminder))
    }

    private func onErrorPopupDismiss() {
        store.send(.logReminderDetails(action: .errorPopupShown))
    }

    private func onDeleteSuccessPopupDismiss() {
        // Only shown when log is deleted successfully, so we're safe to dismiss
        dismissView()
    }

    private func dismissView() {
        self.presentationMode.wrappedValue.dismiss()
        store.send(.logReminderDetails(action: .screenDidDismiss))
    }

    // Update toggle state vars with state, this ensures that we have smooth toggling
    // Unfortunately we can't grab these values from viewmodel, as that updates after
    private func updateState(with appState: AppState) {
        self.isPushNotificationEnabled = appState.logReminderDetails.isPushNotificationEnabled
    }
}

struct LogReminderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Valid view
            LogReminderDetailView()
                .environmentObject(PreviewRedux.filledStore)
            // Error view
            LogReminderDetailView()
                .environmentObject(PreviewRedux.initialStore)
        }
        .embedInNavigationView()
    }
}
