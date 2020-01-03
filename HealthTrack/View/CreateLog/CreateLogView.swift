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
        var showSuccessDialog: Bool
        let showErrorDialog: Bool
        var isSaveButtonDisabled: Bool {
            !isFormValid || isFormDisabled
        }
        var isFormDisabled: Bool {
            isLoading || showSuccessDialog || showErrorDialog
        }
        
        init(showModal: Binding<Bool>, isFormValid: Bool, isLoading: Bool, createSuccess: Bool, createError: Bool) {
            self._showModal = showModal
            self.isFormValid = isFormValid
            self.showSuccessDialog = createSuccess
            self.showErrorDialog = createError
            self.isLoading = isLoading
        }
    }
    @State(initialValue: false) private var showPicker
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        // TODO: Using unmonitored UIColor here
        UINavigationBar.appearance().backgroundColor = .secondarySystemGroupedBackground
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.normal) {
                LogCategoryView(viewModel: getCategoryPickerViewModel())
                    .padding(.top, CGFloat.Theme.Layout.normal)
                getCategorySpecificView().environmentObject(self.store)
                CreateLogTextField(viewModel: getNotesViewModel())
                Spacer()
            }
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
            .onAppear() {
                self.store.send(.createLog(action: .screenDidShow))
        }
        .withLoadingPopup(show: .constant(self.viewModel.isLoading), text: "Saving")
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
        self.store.send(.createLog(action: .onCreateLogPressed))
    }
    
    private func onSaveSuccessPopupDismiss() {
        self.viewModel.$showModal.wrappedValue.toggle()
    }
    
    private func onSaveErrorPopupDismiss() {
        self.store.send(.createLog(action: .createErrorShown))
    }
    
    private func onCancel() {
        viewModel.showModal.toggle()
    }
    
    private func onSelectedCategoryChange(newVal: Int) {
        self.store.send(.createLog(action: CreateLogAction.logCategoryDidChange(newIndex: newVal)))
    }
    
    private func notesDidChange(note: String) {
        self.store.send(.createLog(action: .noteDidUpdate(note: note)))
    }
    
    func getCategorySpecificView() -> AnyView {
        
        switch store.state.createLog.selectedCategory {
            
        case .note:
            return EmptyView().eraseToAnyView()
        case .symptom:
            return AnyView(EmptyView())
        case .nutrition:
            return NutritionLogView().eraseToAnyView()
        case .activity:
            return AnyView(EmptyView())
        case .mood:
            return MoodLogView().eraseToAnyView()
        case .medication:
            return MedicationLogView().eraseToAnyView()
        }
    }
    
    private func getCategoryPickerViewModel() -> LogCategoryView.ViewModel {
        return LogCategoryView.ViewModel(
            categories: store.state.createLog.allCategories.map {
                $0.displayValue()
            },
            selectedCategory: store.state.createLog.selectedCategoryIndex,
            selectedCategoryDidChange: onSelectedCategoryChange,
            showPicker: $showPicker
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
        isFormValid: true,
        isLoading: false,
        createSuccess: true,
        createError: false
    )
    
    static var previews: some View {
        Group {
            CreateLogView(viewModel: viewModel)
                .environmentObject(AppStore(initialState: AppState(), reducer: AppReducer.reduce))
            
            CreateLogView(viewModel: viewModel)
                .environmentObject(AppStore(initialState: AppState(), reducer: AppReducer.reduce))
                .environment(\.colorScheme, .dark)
        }
    }
}
