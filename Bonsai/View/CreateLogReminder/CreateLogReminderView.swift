import SwiftUI


struct CreateLogReminderView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        // View States
        @Binding var showModal: Bool
        private let isFormValid: Bool
        let isLoading: Bool
        let showSuccessDialog: Bool
        let showErrorDialog: Bool
        var isSaveButtonDisabled: Bool {
            !isFormValid || isFormDisabled
        }
        var isFormDisabled: Bool {
            isLoading || showSuccessDialog || showErrorDialog
        }
        // User states
        let isRecurringReminder: Bool // Unused - @State var is used instead
        let recurringTimeInterval: TimeInterval
        let reminderDate: Date

        init(showModal: Binding<Bool>, state: CreateLogReminderState) {
            // View States
            self._showModal = showModal
            self.isFormValid = state.isValidated
            self.showSuccessDialog = state.saveSuccess
            self.showErrorDialog = state.saveError != nil
            self.isLoading = state.isSaving
            // User States
            self.isRecurringReminder = state.isRecurring
            self.recurringTimeInterval = state.reminderInterval
            self.reminderDate = state.reminderDate
        }
    }
    @State(initialValue: false) private var showIntervalPicker
    @State(initialValue: false) private var showDatePicker
    @State(initialValue: false) private var showTimePicker
    // Workaround for toggle to animate nicely, state should reflect this value
    @State(initialValue: false) private var isRecurring
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: CGFloat.Theme.Layout.normal) {
                    DateTimeFormPickerView(viewModel: self.getDateTimeFormPickerViewModel())
                            .padding(.top, CGFloat.Theme.Layout.normal)
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
                    Spacer()
                }
            }
            .disableInteraction(isDisabled: .constant(self.viewModel.isFormDisabled))
            .background(Color.Theme.backgroundPrimary)
            .navigationBarTitle("Create Reminder")
            .navigationBarItems(
                    leading: Button(action: {
                        self.onCancel()
                    }, label: {
                        Text("Cancel")
                            .font(Font.Theme.normalText)
                            .foregroundColor(Color.Theme.primary)
                    }),
                    trailing: Button(action: {
                        self.onSave()
                    }, label: {
                        Text("Save")
                            .font(Font.Theme.normalBoldText)
                            .foregroundColor(self.viewModel.isSaveButtonDisabled ? Color.Theme.grayscalePrimary : Color.Theme.primary)
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
        self.isRecurring.toggle()
        self.store.send(.createLogReminder(action: .isRecurringDidChange(isRecurring: isRecurring)))
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

    // View Models
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

}

struct CreateLogReminderView_Previews: PreviewProvider {

    static let viewModel = CreateLogReminderView.ViewModel(
        showModal: .constant(true),
        state: PreviewRedux.initialStore.state.createLogReminder
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
