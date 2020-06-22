//
//  LogReminderDetailView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-14.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

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
        let logReminder: LogReminder

        init(state: AppState) {
            self.isLoading = state.logReminderDetails.isDeleting
            self.showDeleteSuccess = state.logReminderDetails.deleteSuccess
            let logReminder = state.logReminderDetails.logReminder
            self.showDeleteError = state.logReminderDetails.deleteError != nil
            self.showErrorView = logReminder == nil
            self.logReminder = logReminder ?? ViewModel.EmptyLogReminder
        }
    }
    // MARK: View models
    private var viewModel: ViewModel { ViewModel(state: store.state) }
    private var logReminderDetailSectionViewVm: LogReminderDetailSectionView.ViewModel {
        LogReminderDetailSectionView.ViewModel(
            logReminder: self.viewModel.logReminder,
            hasNotificationPermissions: store.state.global.hasNotificationPermissions,
            isPushNotificationEnabledBinding: Binding<Bool>(get: {
                self.isPushNotificationEnabled
            }, set: { newVal in
                self.isPushNotificationEnabledDidChange(isEnabled: newVal)
            })
        )
    }
    private var logReminderLogDetailSectionViewVm: LogReminderLogDetailSectionView.ViewModel {
        LogReminderLogDetailSectionView.ViewModel(loggable: self.viewModel.logReminder.templateLoggable)
    }
    private var editReminderViewVm: RoundedButtonView.ViewModel {
        RoundedButtonView.ViewModel(
            text: "Edit Reminder",
            textColor: self.viewModel.disableActions ? Color.Theme.SecondaryText : Color.Theme.Primary,
            onTap: self.onEditReminderTapped
        )
    }

    // Main View
    var mainBody: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.Normal) {
                // Reminder Info
                LogReminderDetailSectionView(vm: self.logReminderDetailSectionViewVm)
                // Loggable info
                LogReminderLogDetailSectionView(vm: self.logReminderLogDetailSectionViewVm)
                // Edit Reminder Button
                RoundedButtonView(vm: self.editReminderViewVm)
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
                FullScreenErrorView()
            } else {
                mainBody
            }
        }
        .navigationBarItems(
            trailing: Button(action: {
                self.onDeleteReminderTapped()
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

    private func onEditReminderTapped() {
        // Init edit log reminder state
        store.send(.createLogReminder(action: .initEditLogReminder(
            existingReminder: self.viewModel.logReminder,
            updateLogReminderDetailOnSuccess: true
        )))
        // Show modal
        store.send(.global(action: .changeCreateLogReminderModalDisplay(shouldDisplay: true)))
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
