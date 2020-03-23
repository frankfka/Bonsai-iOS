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
        @Binding var showModal: Bool
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
        
        init(showModal: Binding<Bool>, state: CreateLogState) {
            self._showModal = showModal
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
    @State(initialValue: false) private var showCategoryPicker
    @State(initialValue: false) private var showDatePicker
    @State(initialValue: false) private var showTimePicker
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.normal) {
                CreateLogCategoryPicker(viewModel: getCategoryPickerViewModel())
                    .padding(.top, CGFloat.Theme.Layout.normal)
                DateTimeFormPickerView(viewModel: getCreateLogDateTimePickerViewModel())
                getCategorySpecificView()
                CreateLogTextField(viewModel: getNotesViewModel())
                Spacer()
            }
            .keyboardAwarePadding()
        }
        .disableInteraction(isDisabled: .constant(self.viewModel.isFormDisabled))
        .background(Color.Theme.backgroundPrimary)
        .navigationBarTitle("Add Log")
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
                    .font(Font.Theme.boldNormalText)
                    .foregroundColor(viewModel.isSaveButtonDisabled ? Color.Theme.grayscalePrimary : Color.Theme.primary)
            })
                .disabled(viewModel.isSaveButtonDisabled)
        )
        .embedInNavigationView()
        .withLoadingPopup(show: .constant(self.viewModel.isLoading), text: self.viewModel.loadMessage)
        .withStandardPopup(show: .constant(self.viewModel.showSuccessDialog), type: .success, text: "Saved Successfully") {
            self.onSaveSuccessPopupDismiss()
        }
        .withStandardPopup(show: .constant(self.viewModel.showErrorDialog), type: .failure, text: "Something Went Wrong") {
            self.onSaveErrorPopupDismiss()
        }
    }
    
    private func onSave() {
        // Hide the keyboard
        UIApplication.shared.hideKeyboard()
        self.store.send(.createLog(action: .onSavePressed))
    }
    
    private func onSaveSuccessPopupDismiss() {
        self.viewModel.$showModal.wrappedValue.toggle()
    }
    
    private func onSaveErrorPopupDismiss() {
        self.store.send(.createLog(action: .saveErrorShown))
    }
    
    private func onCancel() {
        viewModel.showModal.toggle()
    }
    
    private func onSelectedCategoryChange(newVal: Int) {
        self.store.send(.createLog(action: CreateLogAction.logCategoryDidChange(newIndex: newVal)))
    }

    private func onLogDateChange(newDate: Date) {
        self.store.send(.createLog(action: .dateDidChange(newDate: newDate)))
    }
    
    private func notesDidChange(note: String) {
        self.store.send(.createLog(action: .noteDidUpdate(note: note)))
    }
    
    func getCategorySpecificView() -> AnyView {
        
        switch store.state.createLog.selectedCategory {
        case .note:
            return EmptyView().eraseToAnyView()
        case .symptom:
            return SymptomLogView().eraseToAnyView()
        case .nutrition:
            return NutritionLogView().eraseToAnyView()
        case .activity:
            return ActivityLogView().eraseToAnyView()
        case .mood:
            return MoodLogView().eraseToAnyView()
        case .medication:
            return MedicationLogView().eraseToAnyView()
        }
    }
    
    private func getCategoryPickerViewModel() -> CreateLogCategoryPicker.ViewModel {
        return CreateLogCategoryPicker.ViewModel(
            categories: store.state.createLog.allCategories.map {
                $0.displayValue()
            },
            selectedCategory: store.state.createLog.selectedCategoryIndex,
            selectedCategoryDidChange: onSelectedCategoryChange,
            showPicker: $showCategoryPicker
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
        return CreateLogTextField.ViewModel(label: "Notes", input: Binding(get: {
            return self.store.state.createLog.notes
        }) { (newNote) in
            self.notesDidChange(note: newNote)
        })
    }
    
}

struct CreateLogView_Previews: PreviewProvider {

    static let viewModel = CreateLogView.ViewModel(
        showModal: .constant(true),
        state: PreviewRedux.initialStore.state.createLog
    )

    static var previews: some View {
        Group {
            CreateLogView(viewModel: viewModel)
                .environmentObject(PreviewRedux.initialStore)

            CreateLogView(viewModel: viewModel)
                .environmentObject(PreviewRedux.initialStore)
                .environment(\.colorScheme, .dark)
        }
    }
}
