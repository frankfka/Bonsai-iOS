//
//  CreateLogView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct CreateLogView: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        private let isFormValid: Bool
        let isLoading: Bool
        let loadMessage: String
        let showSuccessDialog: Bool
        let showErrorDialog: Bool
        var isSaveButtonDisabled: Bool {
            !isFormValid || isFormDisabled
        }
        var isFormDisabled: Bool {
            isLoading || showSuccessDialog || showErrorDialog
        }
        
        init(state: CreateLogState) {
            self.isFormValid = state.isValidated
            self.showSuccessDialog = state.createSuccess
            self.showErrorDialog = state.createError != nil
            self.isLoading = state.isCreatingLog || state.isLoading
            var loadMessage: String = "Loading"
            if state.isCreatingLog {
                loadMessage = "Saving"
            }
            self.loadMessage = loadMessage
        }
    }
    @State(initialValue: false) private var showDatePicker
    @State(initialValue: false) private var showTimePicker
    // Text states - using Redux for every EditText change impacts performance
    @State(initialValue: "") private var notesText
    @State(initialValue: "") private var nutritionAmountText
    @State(initialValue: "") private var medicationDosageText
    private var viewModel: ViewModel {
        ViewModel(state: self.store.state.createLog)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.Normal) {
                RowPickerView(viewModel: getCategoryPickerViewModel())
                    .padding(.top, CGFloat.Theme.Layout.Normal)
                DateTimeFormPickerView(viewModel: getCreateLogDateTimePickerViewModel())
                getCategorySpecificView()
                CreateLogTextField(viewModel: getNotesViewModel())
                Spacer()
            }
            .keyboardAwarePadding()
            .padding(.bottom, CGFloat.Theme.Layout.Normal) // Bottom padding for safe area
        }
        .onAppear {
            // Update state vars to match that of store on initial appear
            self.updateState(with: self.store.state)
        }
        .disabled(self.viewModel.isFormDisabled)
        .navigationBarTitle("Add Log")
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
                    .foregroundColor(viewModel.isSaveButtonDisabled ? Color.Theme.GrayscalePrimary : Color.Theme.Primary)
            })
            .disabled(viewModel.isSaveButtonDisabled)
        )
        .background(Color.Theme.BackgroundPrimary)
        .embedInNavigationView()
        .edgesIgnoringSafeArea(.bottom) // Allow background to cover the bottom safe area
        .withLoadingPopup(show: .constant(self.viewModel.isLoading), text: self.viewModel.loadMessage)
        .withStandardPopup(show: .constant(self.viewModel.showSuccessDialog), type: .success, text: "Saved Successfully") {
            self.onSaveSuccessPopupDismiss()
        }
        .withStandardPopup(show: .constant(self.viewModel.showErrorDialog), type: .failure, text: "Something Went Wrong") {
            self.onSaveErrorPopupDismiss()
        }
    }

    private func updateState(with newState: AppState) {
        self.notesText = newState.createLog.notes
        self.nutritionAmountText = newState.createLog.nutrition.amount
        self.medicationDosageText = newState.createLog.medication.dosage
    }
    
    private func onSave() {
        // Hide the keyboard
        UIApplication.shared.hideKeyboard()
        // Update all the textboxes
        self.updateNoteTextInState()
        self.updateNutritionAmountTextInState()
        self.updateMedicationDosageTextInState()

        // Begin saving
        self.store.send(.createLog(action: .onSavePressed))
    }
    
    private func onSaveSuccessPopupDismiss() {
        // Dismiss the modal
        store.send(.global(action: .changeCreateLogModalDisplay(shouldDisplay: false)))
        // Reset view state
        store.send(.createLog(action: .resetCreateLogState))
    }
    
    private func onSaveErrorPopupDismiss() {
        self.store.send(.createLog(action: .saveErrorShown))
    }
    
    private func onCancel() {
        // Dismiss the modal
        store.send(.global(action: .changeCreateLogModalDisplay(shouldDisplay: false)))
    }
    
    private func onSelectedCategoryChange(newVal: Int) {
        self.store.send(.createLog(action: CreateLogAction.logCategoryDidChange(newIndex: newVal)))
    }

    private func onLogDateChange(newDate: Date) {
        self.store.send(.createLog(action: .dateDidChange(newDate: newDate)))
    }

    // Text fields
    private func updateNoteTextInState() {
        self.store.send(.createLog(action: .noteDidUpdate(note: self.notesText)))
    }
    private func updateNutritionAmountTextInState() {
        self.store.send(.createLog(action: .nutritionAmountDidChange(newAmount: self.nutritionAmountText)))
    }
    private func updateMedicationDosageTextInState() {
        self.store.send(.createLog(action: .medicationDosageDidChange(newDosage: self.medicationDosageText)))
    }

    func getCategorySpecificView() -> AnyView {
        
        switch store.state.createLog.selectedCategory {
        case .note:
            return EmptyView().eraseToAnyView()
        case .symptom:
            return SymptomLogView().eraseToAnyView()
        case .nutrition:
            return NutritionLogView(nutritionAmountTextBinding: self.$nutritionAmountText).eraseToAnyView()
        case .activity:
            return ActivityLogView().eraseToAnyView()
        case .mood:
            return MoodLogView().eraseToAnyView()
        case .medication:
            return MedicationLogView(medicationDosageTextBinding: self.$medicationDosageText).eraseToAnyView()
        }
    }

    struct CategoryPickerValue: RowPickerValue {
        let pickerDisplay: String
    }

    private func getCategoryPickerViewModel() -> RowPickerView.ViewModel {
        let allValues = store.state.createLog.allCategories.map { CategoryPickerValue(pickerDisplay: $0.displayValue()) }
        let selectedIndex = store.state.createLog.selectedCategoryIndex
        let rowValue = allValues[selectedIndex].pickerDisplay
        let selectionBinding = Binding<Int>(get: {
            return selectedIndex
        }, set: { newVal in
            self.onSelectedCategoryChange(newVal: newVal)
        })
        return RowPickerView.ViewModel(
            rowTitle: "Category",
            rowValue: rowValue,
            values: allValues,
            selectionIndex: selectionBinding
        )
    }

    private func getCreateLogDateTimePickerViewModel() -> DateTimeFormPickerView.ViewModel {
        return DateTimeFormPickerView.ViewModel(
                selectedDate: store.state.createLog.date,
                showDatePicker: $showDatePicker,
                showTimePicker: $showTimePicker,
                isForwardLookingRange: false,
                onDateChange:  { newDate in
                    self.onLogDateChange(newDate: newDate)
                }
        )
    }
    
    private func getNotesViewModel() -> CreateLogTextField.ViewModel {
        // Use state instead of redux store to improve performance
        return CreateLogTextField.ViewModel(
            label: "Notes",
            input: self.$notesText,
            onTextCommit: { self.updateNoteTextInState() }
        )
    }
    
}

struct CreateLogView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            CreateLogView()
                .environmentObject(PreviewRedux.initialStore)

            CreateLogView()
                .environmentObject(PreviewRedux.initialStore)
                .environment(\.colorScheme, .dark)
        }
    }
}
