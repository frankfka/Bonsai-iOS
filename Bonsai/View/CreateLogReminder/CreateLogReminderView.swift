import SwiftUI


struct CreateLogReminderView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        // View States
        private let isFormValid: Bool
        private let hasNotificationPermissions: Bool
        let isEditing: Bool // If we're editing a log reminder rather than creating one - we default to creating
        let isLoading: Bool
        let showSuccessDialog: Bool
        let showErrorDialog: Bool
        var isSaveButtonDisabled: Bool {
            !isFormValid || isFormDisabled
        }
        var isFormDisabled: Bool {
            isLoading || showSuccessDialog || showErrorDialog
        }
        var showNoNotificationPermissionsText: Bool {
            !hasNotificationPermissions && isPushNotificationEnabled
        }
        // User states
        let isRecurringReminder: Bool
        let isPushNotificationEnabled: Bool
        let recurringTimeInterval: TimeInterval
        let reminderDate: Date

        init(state: AppState) {
            // View States
            self.isEditing = state.createLogReminder.existingLogReminder != nil
            self.isFormValid = state.createLogReminder.isValidated
            self.showSuccessDialog = state.createLogReminder.saveSuccess
            self.showErrorDialog = state.createLogReminder.saveError != nil
            self.isLoading = state.createLogReminder.isSaving
            // User States
            self.isRecurringReminder = state.createLogReminder.isRecurring
            self.isPushNotificationEnabled = state.createLogReminder.isPushNotificationEnabled
            self.recurringTimeInterval = state.createLogReminder.reminderInterval
            self.reminderDate = state.createLogReminder.reminderDate
            self.hasNotificationPermissions = state.global.hasNotificationPermissions
        }
    }
    private var viewModel: ViewModel {
        ViewModel(state: self.store.state)
    }
    @State(initialValue: false) private var showIntervalPicker
    @State(initialValue: false) private var showDatePicker
    @State(initialValue: false) private var showTimePicker

    // Use state vars for toggle to animate nicely. These are updated in `updateState` on AppState change
    @State(initialValue: false) private var isRecurring
    @State(initialValue: false) private var isPushNotificationEnabled

    // MARK: Child view models
    private var dateTimeFormPickerViewVm: DateTimeFormPickerView.ViewModel {
        DateTimeFormPickerView.ViewModel(
            selectedDate: viewModel.reminderDate, showDatePicker: $showDatePicker, showTimePicker: $showTimePicker,
            isForwardLookingRange: true, datePickerLabel: "Reminder Date", timePickerLabel: "Reminder Time",
            onDateChange: { newDate in
                self.reminderDateDidChange(newDate: newDate)
        })
    }
    private var logReminderIntervalPickerViewVm: LogReminderIntervalPickerView.ViewModel {
        LogReminderIntervalPickerView.ViewModel(
            selectedInterval: viewModel.recurringTimeInterval,
            showPicker: $showIntervalPicker
        ) { newIntervalSelection in
            self.reminderIntervalDidChange(newIntervalSelection: newIntervalSelection)
        }
    }
    private var isRecurringToggleViewVm: ToggleRowView.ViewModel {
        ToggleRowView.ViewModel(title: .constant("Recurring"), value: Binding<Bool>(get: {
            self.isRecurring
        }, set: { isRecurring in
            self.isRecurringDidChange(isRecurring: isRecurring)
        }))
    }
    private var isPushNotificationsEnabledViewVm: ToggleRowView.ViewModel {
        ToggleRowView.ViewModel(
            title: .constant("Push Notification"),
            description: self.viewModel.showNoNotificationPermissionsText ?
                .constant("Notifications permissions are currently disabled. Permissions must be enabled manually in iPhone settings.") : .constant(nil),
            value: Binding<Bool>(get: {
                self.isPushNotificationEnabled
            }, set: { isEnabled in
                self.isPushNotificationEnabledDidChange(isEnabled: isEnabled)
            })
        )
    }

    // MARK: Main view
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: CGFloat.Theme.Layout.Normal) {
                    // Pick date and time for reminder
                    DateTimeFormPickerView(viewModel: self.dateTimeFormPickerViewVm)
                            .padding(.top, CGFloat.Theme.Layout.Normal)
                    // Pick whether the reminder is recurring
                    VStack(spacing: 0) {
                        ToggleRowView(viewModel: self.isRecurringToggleViewVm)
                        if self.viewModel.isRecurringReminder {
                            Divider()
                            LogReminderIntervalPickerView(
                                viewModel: self.logReminderIntervalPickerViewVm,
                                geometry: geometry
                            )
                        }
                    }
                    // Pick whether to enable push notifications
                    ToggleRowView(viewModel: self.isPushNotificationsEnabledViewVm)
                    Spacer()
                }
            }
            .disabled(self.viewModel.isFormDisabled)
            .background(Color.Theme.BackgroundPrimary)
            .navigationBarTitle("\(self.viewModel.isEditing ? "Edit" : "Create") Reminder")
            .navigationBarItems(
                leading: Button(action: {
                    self.onCancel()
                }, label: {
                    Text("Cancel")
                        .font(Font.Theme.NormalText)
                        .foregroundColor(Color.Theme.Primary)
                }),
                trailing: Button(action: {
                    self.onSave()
                }, label: {
                    Text("Save")
                        .font(Font.Theme.NormalBoldText)
                        .foregroundColor(self.viewModel.isSaveButtonDisabled ? Color.Theme.GrayscalePrimary : Color.Theme.Primary)
                })
                .disabled(self.viewModel.isSaveButtonDisabled)
            )
            .embedInNavigationView()
            .withLoadingPopup(show: .constant(self.viewModel.isLoading), text: "Saving")
            .withStandardPopup(show: .constant(self.viewModel.showSuccessDialog), type: .success, text: "Saved Successfully") {
                self.onSaveSuccessPopupDismiss()
            }
            .withStandardPopup(show: .constant(self.viewModel.showErrorDialog), type: .failure, text: "Something Went Wrong") {
                self.onSaveErrorPopupDismiss()
            }
            .onAppear {
                self.store.send(.createLogReminder(action: .screenDidShow))
            }
            .onReceive(self.store.$state) { newState in
                self.updateState(with: newState)
            }
        }
    }

    // Actions
    private func reminderDateDidChange(newDate: Date) {
        self.store.send(.createLogReminder(action: .reminderDateDidChange(newDate: newDate)))
    }

    private func reminderIntervalDidChange(newIntervalSelection: TimeInterval) {
        self.store.send(.createLogReminder(action: .reminderIntervalDidChange(newInterval: newIntervalSelection)))
    }

    private func isRecurringDidChange(isRecurring: Bool) {
        self.store.send(.createLogReminder(action: .isRecurringDidChange(isRecurring: isRecurring)))
    }

    private func isPushNotificationEnabledDidChange(isEnabled: Bool) {
        self.store.send(.createLogReminder(action: .isPushNotificationEnabledDidChange(isEnabled: isEnabled)))
    }

    private func onSave() {
        self.store.send(.createLogReminder(action: .onSavePressed))
    }

    private func onSaveSuccessPopupDismiss() {
        // Dismiss the modal
        store.send(.global(action: .changeCreateLogReminderModalDisplay(shouldDisplay: false)))
        // Reset view state
        store.send(.createLogReminder(action: .resetState))
    }

    private func onSaveErrorPopupDismiss() {
        store.send(.createLogReminder(action: .saveErrorShown))
    }

    private func onCancel() {
        // Dismiss the modal
        store.send(.global(action: .changeCreateLogReminderModalDisplay(shouldDisplay: false)))
    }

    // Update toggle state vars with state, this ensures that we have smooth toggling
    // Unfortunately we can't grab these values from viewmodel, as that updates after
    private func updateState(with appState: AppState) {
        self.isPushNotificationEnabled = appState.createLogReminder.isPushNotificationEnabled
        self.isRecurring = appState.createLogReminder.isRecurring
    }
}

struct CreateLogReminderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateLogReminderView()
                .environmentObject(PreviewRedux.initialStore)

            CreateLogReminderView()
                .environmentObject(PreviewRedux.initialStore)
                .environment(\.colorScheme, .dark)
        }
    }
}
