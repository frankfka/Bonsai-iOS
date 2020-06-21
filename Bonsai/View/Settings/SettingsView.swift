import SwiftUI
import GoogleSignIn

typealias SettingsChangedCallback = (User.Settings) -> Void

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        let showLoading: Bool
        let errorMessage: String
        private let settingsDidChange: Bool
        var showError: Bool {
            !errorMessage.isEmpty
        }
        let successMessage: String
        var showSuccess: Bool {
            !successMessage.isEmpty
        }
        var interactionDisabled: Bool {
            showLoading || showError || showSuccess
        }
        var saveButtonDisabled: Bool {
            !settingsDidChange || interactionDisabled
        }

        init(showLoading: Bool, errorMessage: String, settingsDidChange: Bool, successMessage: String) {
            self.showLoading = showLoading
            self.errorMessage = errorMessage
            self.settingsDidChange = settingsDidChange
            self.successMessage = successMessage
        }

    }
    private var viewModel: ViewModel { getViewModel() }
    
    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.Normal) {
                TitledSection(sectionTitle: "Account") {
                    AccountSettingsSection(viewModel: self.getAccountSectionViewModel())
                }
                .padding(.top, CGFloat.Theme.Layout.Normal)
                TitledSection(sectionTitle: "Analytics") {
                    AnalyticsSettingsSection(viewModel: self.getAnalyticsSectionViewModel())
                }
                // Save Button
                RoundedButtonView(viewModel: self.getSaveButtonViewModel())
                    .disabled(self.viewModel.saveButtonDisabled)
            }
        }
        // TODO: Declaring background breaks scrollview collapse navigation title behavior
        .background(Color.Theme.BackgroundPrimary)
        .withLoadingPopup(show: .constant(viewModel.showLoading), text: "Loading")
        .withStandardPopup(show: .constant(viewModel.showSuccess), type: .success, text: viewModel.successMessage) {
            self.successPopupShown()
        }
        .withStandardPopup(show: .constant(viewModel.showError), type: .failure, text: viewModel.errorMessage) {
            self.errorPopupShown()
        }
        .navigationBarTitle("Settings")
    }

    // MARK: Actions
    private func successPopupShown() {
        store.send(.settings(action: .successPopupShown))
    }

    private func errorPopupShown() {
        store.send(.settings(action: .errorPopupShown))
    }

    private func onSettingsChanged(newSettings: User.Settings) {
        store.send(.settings(action: .settingsDidChange(newSettings: newSettings)))
    }

    private func onSaveTapped() {
        store.send(.settings(action: .saveSettingsPressed))
    }

    // TODO: To computed vars
    // MARK: View Model
    private func getViewModel() -> ViewModel {
        let showLoading = store.state.settings.isLoading
        // Create success message
        var successMessage = ""
        if store.state.settings.accountRestoreSuccess {
            successMessage = "Account Restored"
        } else if store.state.settings.linkGoogleAccountSuccess {
            successMessage = "Account Linked"
        } else if store.state.settings.unlinkGoogleAccountSuccess {
            successMessage = "Account Unlinked"
        } else if store.state.settings.saveSettingsSuccess {
            successMessage = "Settings Saved"
        }
        // Create error message
        var errorMessage = ""
        if store.state.settings.linkGoogleAccountError != nil {
            errorMessage = "Something Went Wrong"
        } else if store.state.settings.googleSignInError != nil {
            errorMessage = "Could Not Sign In"
        } else if store.state.settings.unlinkGoogleAccountError != nil {
            errorMessage = "Could Not Unlink"
        } else if store.state.settings.saveSettingsError != nil {
            errorMessage = "Error Saving Settings"
        }
        return ViewModel(
            showLoading: showLoading,
            errorMessage: errorMessage,
            settingsDidChange: store.state.settings.settingsDidChange,
            successMessage: successMessage
        )
    }

    private func getAccountSectionViewModel() -> AccountSettingsSection.ViewModel {
        let googleSignInEmail = store.state.global.user?.linkedFirebaseGoogleAccount?.email
        let showRestoreDialog = store.state.settings.existingUserWithLinkedGoogleAccount != nil
        return AccountSettingsSection.ViewModel(
            linkedGoogleAccountEmail: googleSignInEmail ?? "Not Signed In",
            isSignedIn: googleSignInEmail != nil,
            showRestoreDialog: showRestoreDialog,
            interactionDisabled: viewModel.interactionDisabled
        )
    }

    private func getAnalyticsSectionViewModel() -> AnalyticsSettingsSection.ViewModel {
        return AnalyticsSettingsSection.ViewModel(
            settings: store.state.settings.settings,
            onSettingsChanged: self.onSettingsChanged
        )
    }

    private func getSaveButtonViewModel() -> RoundedButtonView.ViewModel {
        return RoundedButtonView.ViewModel(
                text: "Save",
                textColor: self.viewModel.saveButtonDisabled ? Color.Theme.SecondaryText : Color.Theme.Primary,
                onTap: self.onSaveTapped
        )
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
