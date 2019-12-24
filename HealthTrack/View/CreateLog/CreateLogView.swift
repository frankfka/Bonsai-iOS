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
        let isSaveButtonDisabled: Bool

        init(showModal: Binding<Bool>, isSaveButtonDisabled: Bool) {
            self._showModal = showModal
            self.isSaveButtonDisabled = isSaveButtonDisabled
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
        NavigationView {
            VStack(spacing: CGFloat.Theme.Layout.normal) {
                LogCategoryView(viewModel: getCategoryPickerViewModel())
                        .padding(.top, CGFloat.Theme.Layout.normal)
                getCategorySpecificView().environmentObject(self.store)
                CreateLogTextField(viewModel: getNotesViewModel())
                Spacer()
            }
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
        }
        .onAppear() {
            self.store.send(.createLog(action: .screenDidShow))
        }
    }

    private func onSave() {
        // Some async save job, need to show loading
        print("Show loading")
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
            return AnyView(EmptyView())
        case .symptom:
            return AnyView(EmptyView())
        case .nutrition:
            return AnyView(EmptyView())
        case .activity:
            return AnyView(EmptyView())
        case .mood:
            return AnyView(EmptyView())
        case .medication:
            return AnyView(MedicationLogView())
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
    static var previews: some View {
        Group {
            CreateLogView(viewModel: CreateLogView.ViewModel(showModal: .constant(true), isSaveButtonDisabled: false))
                    .environmentObject(AppStore(initialState: AppState(), reducer: appReducer))

            CreateLogView(viewModel: CreateLogView.ViewModel(showModal: .constant(true), isSaveButtonDisabled: true))
                    .environmentObject(AppStore(initialState: AppState(), reducer: appReducer))
                    .environment(\.colorScheme, .dark)
        }
    }
}