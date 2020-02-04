//
//  LogDetailView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-01-14.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogDetailView: View {

    // Shown in case of error, when we don't have a loggable in the state
    private static let ErrorLoggablePlaceholder = NoteLog(id: "", title: "", dateCreated: Date(), notes: "")

    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    struct ViewModel {
        let loggable: Loggable
        let logDate: String
        let logCategory: String
        let logCategoryColor: Color
        let isLoading: Bool
        let showDeleteSuccess: Bool
        let showError: Bool
        var loadingMessage: String = "Loading"
        var errorMessage: String = "Error"

        var disableActions: Bool {
            isLoading || showDeleteSuccess || showError
        }
        var disableDelete: Bool {
            disableActions || loggable.id.isEmptyWithoutWhitespace()
        }

        init(loggable: Loggable, isLoading: Bool = false, loadingMessage: String = "Loading",
             showDeleteSuccess: Bool = false, showError: Bool = false, errorMessage: String = "Error") {
            self.loggable = loggable
            self.logDate = loggable.dateCreated.description
            self.logCategory = loggable.category.displayValue()
            self.logCategoryColor = loggable.category.displayColor()
            self.loadingMessage = loadingMessage
            self.isLoading = isLoading
            self.showDeleteSuccess = showDeleteSuccess
            self.errorMessage = errorMessage
            self.showError = showError
        }
    }
    private var viewModel: ViewModel {
        if let loggable = store.state.logDetails.loggable {
            let isLoading = store.state.logDetails.isLoading || store.state.logDetails.isDeleting
            let showDeleteSuccess = store.state.logDetails.deleteSuccess
            let showError = store.state.logDetails.loadError != nil || store.state.logDetails.deleteError != nil
            let loadingMessage = store.state.logDetails.isDeleting ? "Deleting Log" : "Loading"
            let errorMessage = store.state.logDetails.deleteError != nil ? "Error Deleting Log" : "Error Loading Log"
            return ViewModel(
                    loggable: loggable,
                    isLoading: isLoading,
                    loadingMessage: loadingMessage,
                    showDeleteSuccess: showDeleteSuccess,
                    showError: showError,
                    errorMessage: errorMessage
            )
        } else {
            return ViewModel(loggable: LogDetailView.ErrorLoggablePlaceholder)
        }
    }
    @State(initialValue: false) var showCreateLogModal: Bool
    @State(initialValue: false) var showDeleteLogConfirmation: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.normal) {
                // Detail Views
                LogDetailBasicsView(viewModel: getBasicDetailsViewModel())
                getCategorySpecificView()
                LogDetailNotesView(viewModel: getNotesViewModel())
                // Quick Re-log button
                RoundedBorderButtonView(viewModel: getLogAgainButtonViewModel())
                    .padding(.top, CGFloat.Theme.Layout.normal)
                    .disabled(self.viewModel.disableActions)
            }
            .padding(.vertical, CGFloat.Theme.Layout.normal)
        }
        .background(Color.Theme.backgroundPrimary)
        .navigationBarItems(
                trailing: Button(action: {
                        self.onDeleteLogTapped()
                    }, label: {
                        Image(systemName: "trash")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(height: CGFloat.Theme.Layout.navBarItemHeight)
                                .foregroundColor(
                                        self.viewModel.disableDelete ?
                                        Color.Theme.grayscalePrimary : Color.Theme.primary
                                )
                    })
                    .disabled(self.viewModel.disableDelete)
        )
        .navigationBarTitle("Log Details", displayMode: .inline)
        // Delete Log Confirmation
        .alert(isPresented: $showDeleteLogConfirmation) {
            Alert(
                title: Text("Delete Log"),
                message: Text("Are you sure you want to delete this log?"),
                primaryButton: .destructive(
                    Text("Confirm"),
                    action: {
                        self.onDeleteLogConfirmed()
                }),
                secondaryButton: .cancel(
                    Text("Cancel")
                )
            )
        }
        // Create Log Modal
        .sheet(
            isPresented: $showCreateLogModal,
            onDismiss: {
                self.onCreateLogModalDismiss()
            }) {
                CreateLogView(
                        viewModel: self.getCreateLogModalViewModel()
                ).environmentObject(self.store)
        }
        // Popups
        .withLoadingPopup(show: .constant(self.viewModel.isLoading), text: self.viewModel.loadingMessage)
        .withStandardPopup(show: .constant(self.viewModel.showError), type: .failure, text: self.viewModel.errorMessage) {
            self.onErrorPopupDismiss()
        }
        .withStandardPopup(show: .constant(self.viewModel.showDeleteSuccess), type: .success, text: "Deleted Successfully") {
            self.onDeleteSuccessPopupDismiss()
        }
    }
    
    // MARK: Actions
    private func onBackTapped() {
        dismissView()
    }

    private func onLogAgainTapped() {
        // Dispatch an action for logging that will initialize the state
        store.send(.createLog(action: .initFromPreviousLog(loggable: self.viewModel.loggable)))
        showCreateLogModal.toggle()
    }

    private func onCreateLogModalDismiss() {
        store.send(.createLog(action: .screenDidDismiss))
    }
    
    private func onDeleteLogTapped() {
        // Show alert
        showDeleteLogConfirmation.toggle()
    }
    
    private func onDeleteLogConfirmed() {
        // Dispatch action to delete the log
        store.send(.logDetails(action: .deleteCurrentLog))
    }

    private func onErrorPopupDismiss() {
        // Tell store to reset all errors so we hide the prompt
        store.send(.logDetails(action: .errorPopupShown))
    }

    private func onDeleteSuccessPopupDismiss() {
        // Only shown when log is deleted successfully, so we're safe to dismiss
        dismissView()
    }

    private func dismissView() {
        store.send(.logDetails(action: .screenDidDismiss))
        self.presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: Rendered for all logs
    private func getBasicDetailsViewModel() -> LogDetailBasicsView.ViewModel {
        return LogDetailBasicsView.ViewModel(loggable: self.viewModel.loggable)
    }
    
    private func getNotesViewModel() -> LogDetailNotesView.ViewModel {
        return LogDetailNotesView.ViewModel(notes: self.viewModel.loggable.notes)
    }

    private func getLogAgainButtonViewModel() -> RoundedBorderButtonView.ViewModel {
        return RoundedBorderButtonView.ViewModel(
                text: "Log This Again",
                textColor: self.viewModel.disableActions ? Color.Theme.text : Color.Theme.primary,
                onTap: self.onLogAgainTapped
        )
    }

    private func getCreateLogModalViewModel() -> CreateLogView.ViewModel {
        return CreateLogView.ViewModel(showModal: $showCreateLogModal, createLogState: store.state.createLog)
    }
    
    // MARK: Category-specific views
    private func getCategorySpecificView() -> AnyView {
        switch self.viewModel.loggable.category {
        case .symptom:
            guard let symptomVm = getSymptomDetailViewModel() else {
                AppLogging.warn("Should be showing symptom log details but could not create view model")
                break
            }
            return LogDetailSymptomView(viewModel: symptomVm).eraseToAnyView()
        case .activity:
            guard let activityVm = getActivityDetailViewModel() else {
                AppLogging.warn("Should be showing activity log details but could not create view model")
                break
            }
            return LogDetailActivityView(viewModel: activityVm).eraseToAnyView()
        case .medication:
            guard let medicationVm = getMedicationDetailViewModel() else {
                AppLogging.warn("Should be showing medication log details but could not create view model")
                break
            }
            return LogDetailMedicationView(viewModel: medicationVm).eraseToAnyView()
        case .nutrition:
            guard let nutritionVm = getNutritionDetailViewModel() else {
                AppLogging.warn("Should be showing nutrition log details but could not create view model")
                break
            }
            return LogDetailNutritionView(viewModel: nutritionVm).eraseToAnyView()
        default:
            break
        }
        return EmptyView().eraseToAnyView()
    }
    
    func getSymptomDetailViewModel() -> LogDetailSymptomView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .symptom, let symptomLog = loggable as? SymptomLog else {
            return nil
        }
        let symptomName = symptomLog.selectedSymptom?.name ?? "Unknown"
        return LogDetailSymptomView.ViewModel(name: symptomName, severity: symptomLog.severity.displayValue())
    }

    func getActivityDetailViewModel() -> LogDetailActivityView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .activity, let activityLog = loggable as? ActivityLog else {
            return nil
        }
        let activityName = activityLog.selectedActivity?.name ?? "Unknown"
        return LogDetailActivityView.ViewModel(name: activityName, duration: activityLog.duration)
    }

    func getMedicationDetailViewModel() -> LogDetailMedicationView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .medication, let medicationLog = loggable as? MedicationLog else {
            return nil
        }
        let medicationName = medicationLog.selectedMedication?.name ?? "Unknown"
        return LogDetailMedicationView.ViewModel(name: medicationName, dosage: medicationLog.dosage)
    }

    func getNutritionDetailViewModel() -> LogDetailNutritionView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .nutrition, let nutritionLog = loggable as? NutritionLog else {
            return nil
        }
        let nutritionItemName = nutritionLog.selectedNutritionItem?.name ?? "Unknown"
        return LogDetailNutritionView.ViewModel(name: nutritionItemName, amount: nutritionLog.amount)
    }

}


struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogDetailView()
        }.embedInNavigationView()
    }
}
