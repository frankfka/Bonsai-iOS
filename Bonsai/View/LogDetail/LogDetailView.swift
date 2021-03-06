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
    @State(initialValue: false) var showCreateLogReminderModal: Bool
    @State(initialValue: false) var showDeleteLogConfirmation: Bool

    // MARK: Child view models
    private var basicDetailsViewVm: LogDetailBasicsView.ViewModel {
        return LogDetailBasicsView.ViewModel(loggable: self.viewModel.loggable)
    }

    private var notesViewVm: LogDetailNotesView.ViewModel {
        return LogDetailNotesView.ViewModel(notes: self.viewModel.loggable.notes)
    }

    private var logAgainButtonViewVm: RoundedButtonView.ViewModel {
        return RoundedButtonView.ViewModel(
            text: "Log This Again",
            textColor: self.viewModel.disableActions ? Color.Theme.SecondaryText : Color.Theme.Primary,
            onTap: self.onLogAgainTapped
        )
    }

    private var createLogReminderButtonViewVm: RoundedButtonView.ViewModel {
        return RoundedButtonView.ViewModel(
            text: "Create Reminder",
            textColor: self.viewModel.disableActions ? Color.Theme.SecondaryText : Color.Theme.Primary,
            onTap: self.onCreateLogReminderTapped
        )
    }

    // MARK: Child views

    // Leaving as a function for now, as switch is not supported if we have return type as some View
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
    private func getSymptomDetailViewModel() -> LogDetailSymptomView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .symptom, let symptomLog = loggable as? SymptomLog else {
            return nil
        }
        let symptomName = symptomLog.selectedSymptom?.name ?? "Unknown"
        let severityAnalytics = store.state.logDetails.symptomSeverityAnalytics
        return LogDetailSymptomView.ViewModel(
            name: symptomName,
            severity: symptomLog.severity.displayValue(),
            severityAnalytics: severityAnalytics
        )
    }
    private func getActivityDetailViewModel() -> LogDetailActivityView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .activity, let activityLog = loggable as? ActivityLog else {
            return nil
        }
        let activityName = activityLog.selectedActivity?.name ?? "Unknown"
        return LogDetailActivityView.ViewModel(name: activityName, duration: activityLog.duration)
    }
    private func getMedicationDetailViewModel() -> LogDetailMedicationView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .medication, let medicationLog = loggable as? MedicationLog else {
            return nil
        }
        let medicationName = medicationLog.selectedMedication?.name ?? "Unknown"
        return LogDetailMedicationView.ViewModel(name: medicationName, dosage: medicationLog.dosage)
    }
    private func getNutritionDetailViewModel() -> LogDetailNutritionView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .nutrition, let nutritionLog = loggable as? NutritionLog else {
            return nil
        }
        let nutritionItemName = nutritionLog.selectedNutritionItem?.name ?? "Unknown"
        return LogDetailNutritionView.ViewModel(name: nutritionItemName, amount: nutritionLog.amount)
    }

    // MARK: Main body view
    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.Normal) {
                // Detail Views
                LogDetailBasicsView(viewModel: basicDetailsViewVm)
                getCategorySpecificView()
                LogDetailNotesView(viewModel: notesViewVm)
                        .padding(.bottom, CGFloat.Theme.Layout.Normal)
                Group {
                    // Quick Re-log button
                    RoundedButtonView(vm: logAgainButtonViewVm)
                    // Create Reminder Button
                    RoundedButtonView(vm: createLogReminderButtonViewVm)
                }
                .disabled(self.viewModel.disableActions)
            }
            .padding(.vertical, CGFloat.Theme.Layout.Normal)
        }
        .background(Color.Theme.BackgroundPrimary)
        .navigationBarItems(
                trailing: Button(action: {
                    self.onDeleteLogTapped()
                }, label: {
                    Image.Icons.Trash
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
    // Log Again
    private func onLogAgainTapped() {
        // Dispatch an action for logging that will initialize the state
        store.send(.createLog(action: .initFromPreviousLog(loggable: self.viewModel.loggable)))
        store.send(.global(action: .changeCreateLogModalDisplay(shouldDisplay: true)))
    }

    // Create Reminder
    private func onCreateLogReminderTapped() {
        // Dispatch an action for creating a reminder with the given log
        store.send(.createLogReminder(action: .initCreateLogReminder(template: self.viewModel.loggable)))
        // Dispatch an action to show the modal
        store.send(.global(action: .changeCreateLogReminderModalDisplay(shouldDisplay: true)))
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
}


struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogDetailView()
        }.embedInNavigationView()
    }
}
