import SwiftUI
import GoogleSignIn

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        let linkedGoogleAccountEmail: String?
        let showLoading: Bool
        let errorMessage: String
        let successMessage: String
        let showRestoreDialog: Bool
    }
    private var viewModel: ViewModel { getViewModel() }
    private var googleSignInVc: AuthViewControllerRepresentable = AuthViewControllerRepresentable()
    @State(initialValue: nil) private var navigateToGoogleSignIn: Bool?
    
    var body: some View {
        ScrollView {
            VStack {
                // An empty navigation link for us to programmatically trigger the navigation view
                NavigationLink(
                        destination: googleSignInVc
                                .onAppear {
                            self.navigateToGoogleSignIn = nil
                        },
                        tag: true, selection: $navigateToGoogleSignIn) {
                    EmptyView()
                }
                Text(viewModel.linkedGoogleAccountEmail ?? "Not Signed In")
                Button(action: {
                    self.linkWithGoogleAccountTapped()
                }, label: {
                    Text("Sign In")
                })
            }
        }
        .withLoadingPopup(show: .constant(viewModel.showLoading), text: "Loading")
        .withStandardPopup(show: .constant(!viewModel.successMessage.isEmpty), type: .success, text: viewModel.successMessage) {
            self.successPopupShown()
        }
        .withStandardPopup(show: .constant(!viewModel.errorMessage.isEmpty), type: .failure, text: viewModel.errorMessage) {
            self.errorPopupShown()
        }
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
        .navigationBarTitle("Settings")
    }
    
    // Encapsulates all the code required to display the Google Sign In
    private func linkWithGoogleAccountTapped() {
        // Create the VC. On appear, dispatch an action to dismiss the placeholder view controller
        self.navigateToGoogleSignIn = true
    }

    private func successPopupShown() {
        store.send(.settings(action: .successPopupShown))
    }

    private func errorPopupShown() {
        store.send(.settings(action: .errorPopupShown))
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
    
    private func getViewModel() -> ViewModel {
        let googleSignIn = store.state.global.user?.linkedFirebaseGoogleAccount?.email
        let showLoading = store.state.settings.isLoading
        let showRestoreDialog = store.state.settings.existingUserWithLinkedGoogleAccount != nil
        // Create success message
        var successMessage = ""
        if store.state.settings.accountRestoreSuccess {
            successMessage = "Account Restored"
        } else if store.state.settings.linkGoogleAccountSuccess {
            successMessage = "Account Linked"
        }
        // Create error message
        var errorMessage = ""
        if store.state.settings.linkGoogleAccountError != nil {
            errorMessage = "Something Went Wrong"
        } else if store.state.settings.googleSignInError != nil {
            errorMessage = "Could not Sign In"
        }
        return ViewModel(
            linkedGoogleAccountEmail: googleSignIn,
            showLoading: showLoading,
            errorMessage: errorMessage,
            successMessage: successMessage,
            showRestoreDialog: showRestoreDialog
        )
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
