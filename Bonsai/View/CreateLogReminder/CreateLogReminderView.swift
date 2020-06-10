import SwiftUI


struct CreateLogReminderView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        // View States
        @Binding var showModal: Bool
        private let isFormValid: Bool
        private let hasNotificationPermissions: Bool
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

        init(showModal: Binding<Bool>, state: AppState) {
            // View States
            self._showModal = showModal
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
    @State(initialValue: false) private var showIntervalPicker
    @State(initialValue: false) private var showDatePicker
    @State(initialValue: false) private var showTimePicker

    // Use state vars for toggle to animate nicely. These are updated in `updateState` on AppState change
    @State(initialValue: false) private var isRecurring
    @State(initialValue: false) private var isPushNotificationEnabled
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: CGFloat.Theme.Layout.Normal) {
                    // Pick date and time for reminder
                    DateTimeFormPickerView(viewModel: self.getDateTimeFormPickerViewModel())
                            .padding(.top, CGFloat.Theme.Layout.Normal)
                    // Pick whether the reminder is recurring
                    VStack(spacing: 0) {
                        ToggleRowView(viewModel: self.getIsRecurringToggleViewModel())
                        if self.viewModel.isRecurringReminder {
                            Divider()
                            LogReminderIntervalPickerView(
                                viewModel: self.getLogReminderIntervalPickerViewModel(),
                                geometry: geometry
                            )
                        }
                    }
                    // Pick whether to enable push notifications
                    ToggleRowView(viewModel: self.getIsPushNotificationsEnabledViewModel())
                    Spacer()
                }
            }
            .disabled(self.viewModel.isFormDisabled)
            .background(Color.Theme.BackgroundPrimary)
            .navigationBarTitle("Create Reminder")
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
            .onReceive(self.store.$state) { _ in
                self.updateState()
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
        self.isRecurring = isRecurring
        self.store.send(.createLogReminder(action: .isRecurringDidChange(isRecurring: isRecurring)))
    }

    private func isPushNotificationEnabledDidChange(isEnabled: Bool) {
        self.isPushNotificationEnabled = isEnabled
        store.send(.createLogReminder(action: .isPushNotificationEnabledDidChange(isEnabled: isEnabled)))
    }

    private func onSave() {
        store.send(.createLogReminder(action: .onSavePressed))
    }

    private func onSaveSuccessPopupDismiss() {
        self.viewModel.$showModal.wrappedValue.toggle()
        store.send(.createLogReminder(action: .resetState))
    }

    private func onSaveErrorPopupDismiss() {
        store.send(.createLogReminder(action: .saveErrorShown))
    }

    private func onCancel() {
        viewModel.showModal.toggle()
    }

    private func updateState() {
        self.isPushNotificationEnabled = self.viewModel.isPushNotificationEnabled
        self.isRecurring = self.viewModel.isRecurringReminder
    }

    // View Models TODO: make them computed vars
    private func getDateTimeFormPickerViewModel() -> DateTimeFormPickerView.ViewModel {
        return DateTimeFormPickerView.ViewModel(
            selectedDate: viewModel.reminderDate, showDatePicker: $showDatePicker, showTimePicker: $showTimePicker,
            isForwardLookingRange: true, datePickerLabel: "Reminder Date", timePickerLabel: "Reminder Time",
                onDateChange: { newDate in
            self.reminderDateDidChange(newDate: newDate)
        })
    }

    private func getLogReminderIntervalPickerViewModel() -> LogReminderIntervalPickerView.ViewModel {
        return LogReminderIntervalPickerView.ViewModel(
                selectedInterval: viewModel.recurringTimeInterval,
                showPicker: $showIntervalPicker
        ) { newIntervalSelection in
            self.reminderIntervalDidChange(newIntervalSelection: newIntervalSelection)
        }
    }

    private func getIsRecurringToggleViewModel() -> ToggleRowView.ViewModel {
        return ToggleRowView.ViewModel(title: .constant("Recurring"), value: Binding<Bool>(get: {
            return self.isRecurring
        }, set: { isRecurring in
            self.isRecurringDidChange(isRecurring: isRecurring)
        }))
    }

    private func getIsPushNotificationsEnabledViewModel() -> ToggleRowView.ViewModel {
        return ToggleRowView.ViewModel(
            title: .constant("Push Notification"),
            description: self.viewModel.showNoNotificationPermissionsText ?
                .constant("Notifications permissions are currently disabled. Permissions must be enabled manually in iPhone settings.") : .constant(nil),
            value: Binding<Bool>(get: {
                return self.isPushNotificationEnabled
            }, set: { isEnabled in
                self.isPushNotificationEnabledDidChange(isEnabled: isEnabled)
            })
        )
    }

}

struct CreateLogReminderView_Previews: PreviewProvider {

    static let viewModel = CreateLogReminderView.ViewModel(
        showModal: .constant(true),
        state: PreviewRedux.initialStore.state
    )

    static var previews: some View {
        Group {
            CreateLogReminderView(viewModel: viewModel)
                .environmentObject(PreviewRedux.initialStore)

            CreateLogReminderView(viewModel: viewModel)
                .environmentObject(PreviewRedux.initialStore)
                .environment(\.colorScheme, .dark)
        }
    }
}
