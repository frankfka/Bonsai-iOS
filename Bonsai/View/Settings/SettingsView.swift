import SwiftUI
import GoogleSignIn

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        let linkedGoogleAccountEmail: String
        let showLoading: Bool
        let errorMessage: String
        var showError: Bool {
            !errorMessage.isEmpty
        }
        let successMessage: String
        var showSuccess: Bool {
            !successMessage.isEmpty
        }
        let showRestoreDialog: Bool
        let showSignInButton: Bool
        let showUnlinkButton: Bool
        var interactionDisabled: Bool {
            showLoading || showError || showSuccess
        }
    }
    private var viewModel: ViewModel { getViewModel() }
    private var googleSignInVc: AuthViewControllerRepresentable = AuthViewControllerRepresentable()
    @State(initialValue: nil) private var navigateToGoogleSignIn: Bool?
    @State(initialValue: false) private var showUnlinkConfirmationDialog: Bool
    
    var body: some View {
        ScrollView {
            // TODO: Scrollbar no longer works with header, figure out why
            VStack {
                TitledSection(sectionTitle: "Account") {
                    VStack {
                        // An empty navigation link for us to programmatically trigger the navigation view
                        NavigationLink(
                                destination: self.googleSignInVc
                                        .onAppear {
                                    self.navigateToGoogleSignIn = nil
                                },
                                tag: true, selection: self.$navigateToGoogleSignIn) {
                            EmptyView()
                        }
                        TappableRowView(viewModel: self.getSignedInGoogleAccountRowViewModel())
                        VStack {
                            if self.viewModel.showSignInButton {
                                RoundedBorderButtonView(viewModel: self.getLogInWithGoogleButtonViewModel())
                            }
                            if self.viewModel.showUnlinkButton {
                                RoundedBorderButtonView(viewModel: self.getUnlinkButtonViewModel())
                            }
                        }
                        .padding(.top, CGFloat.Theme.Layout.normal)
                        .disabled(self.viewModel.interactionDisabled)
                    }
                }
                .padding(.top, CGFloat.Theme.Layout.normal)
            }
        }
        .background(Color.Theme.backgroundPrimary)
        .withLoadingPopup(show: .constant(viewModel.showLoading), text: "Loading")
        .withStandardPopup(show: .constant(viewModel.showSuccess), type: .success, text: viewModel.successMessage) {
            self.successPopupShown()
        }
        .withStandardPopup(show: .constant(viewModel.showError), type: .failure, text: viewModel.errorMessage) {
            self.errorPopupShown()
        }
        // Restore User Dialog
        .alert(isPresented: .constant(viewModel.showRestoreDialog)) {
            Alert(
                    title: Text("Existing User Found"),
                    message: Text("""
                                  Another user is linked to this account. Do you want to restore the 
                                  account? All current log data will no longer be accessible.
                                  """),
                    primaryButton: .default(
                            Text("Restore"),
                            action: {
                                self.restoreAccountConfirmed()
                            }),
                    secondaryButton: .cancel(
                            Text("Cancel"),
                            action: {
                                self.restoreAccountCanceled()
                            })
            )
        }
        // Confirm Unlink Dialog
        .alert(isPresented: $showUnlinkConfirmationDialog) {
            Alert(
                    title: Text("Unlink Google Account"),
                    message: Text("Are you sure you want to unlink your Google Account?"),
                    primaryButton: .destructive(
                            Text("Unlink"),
                            action: {
                                self.unlinkAccountConfirmed()
                            }),
                    secondaryButton: .cancel(
                            Text("Cancel")
                    )
            )
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

    private func unlinkAccountConfirmed() {
        store.send(.settings(action: .unlinkGoogleAccount))
    }

    private func restoreAccountConfirmed() {
        if let existingUser = store.state.settings.existingUserWithLinkedGoogleAccount {
            store.send(.settings(action: .restoreLinkedAccount(userToRestore: existingUser)))
        } else {
            AppLogging.warn("Showing restore user prompt but no existing user with Google account initialized in the state")
        }
    }

    private func restoreAccountCanceled() {
        store.send(.settings(action: .cancelRestoreLinkedAccount))
    }

    // MARK: View Model
    
    private func getViewModel() -> ViewModel {
        let googleSignInEmail = store.state.global.user?.linkedFirebaseGoogleAccount?.email
        let showLoading = store.state.settings.isLoading
        let showRestoreDialog = store.state.settings.existingUserWithLinkedGoogleAccount != nil
        // Create success message
        var successMessage = ""
        if store.state.settings.accountRestoreSuccess {
            successMessage = "Account Restored"
        } else if store.state.settings.linkGoogleAccountSuccess {
            successMessage = "Account Linked"
        } else if store.state.settings.unlinkGoogleAccountSuccess {
            successMessage = "Account Unlinked"
        }
        // Create error message
        var errorMessage = ""
        if store.state.settings.linkGoogleAccountError != nil {
            errorMessage = "Something Went Wrong"
        } else if store.state.settings.googleSignInError != nil {
            errorMessage = "Could Not Sign In"
        } else if store.state.settings.unlinkGoogleAccountError != nil {
            errorMessage = "Could Not Unlink"
        }
        return ViewModel(
            linkedGoogleAccountEmail: googleSignInEmail ?? "Not Signed In",
            showLoading: showLoading,
            errorMessage: errorMessage,
            successMessage: successMessage,
            showRestoreDialog: showRestoreDialog,
            showSignInButton: googleSignInEmail == nil,
            showUnlinkButton: googleSignInEmail != nil
        )
    }

    private func getSignedInGoogleAccountRowViewModel() -> TappableRowView.ViewModel {
        TappableRowView.ViewModel(
                primaryText: .constant("Google Account"),
                secondaryText: .constant(viewModel.linkedGoogleAccountEmail),
                hasDisclosureIndicator: false
        )
    }

    private func getLogInWithGoogleButtonViewModel() -> RoundedBorderButtonView.ViewModel {
        RoundedBorderButtonView.ViewModel(
                text: "Log In With Google",
                textColor: self.viewModel.interactionDisabled ? Color.Theme.text : Color.Theme.primary
        ) {
            // Create the VC. On appear, dispatch an action to dismiss the placeholder view controller
            self.navigateToGoogleSignIn = true
        }
    }

    private func getUnlinkButtonViewModel() -> RoundedBorderButtonView.ViewModel {
        RoundedBorderButtonView.ViewModel(
                text: "Unlink Account",
                textColor: self.viewModel.interactionDisabled ? Color.Theme.text : Color.Theme.negative
        ) {
            self.showUnlinkConfirmationDialog.toggle()
        }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
