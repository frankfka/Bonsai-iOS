import SwiftUI
import GoogleSignIn

struct AccountSettingsSection: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        let linkedGoogleAccountEmail: String
        let showRestoreDialog: Bool
        let interactionDisabled: Bool
        private let isSignedIn: Bool
        var showSignInButton: Bool {
            !isSignedIn
        }
        var showUnlinkButton: Bool {
            isSignedIn
        }

        init(linkedGoogleAccountEmail: String, isSignedIn: Bool, showRestoreDialog: Bool, interactionDisabled: Bool) {
            self.linkedGoogleAccountEmail = linkedGoogleAccountEmail
            self.isSignedIn = isSignedIn
            self.showRestoreDialog = showRestoreDialog
            self.interactionDisabled = interactionDisabled
        }
    }

    private let viewModel: ViewModel
    private var googleSignInVc: AuthViewControllerRepresentable = AuthViewControllerRepresentable()
    @State(initialValue: nil) private var navigateToGoogleSignIn: Bool?
    @State(initialValue: false) private var showUnlinkConfirmationDialog: Bool

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
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
                    RoundedButtonView(vm: self.getLogInWithGoogleButtonViewModel())
                }
                if self.viewModel.showUnlinkButton {
                    RoundedButtonView(vm: self.getUnlinkButtonViewModel())
                }
            }
            .padding(.top, CGFloat.Theme.Layout.Normal)
            .disabled(self.viewModel.interactionDisabled)
        }
        // Restore User Dialog
        .background(
            EmptyView()
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
        )
        // Confirm Unlink Dialog
        .background(
            EmptyView()
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
        )
    }

    // MARK: Actions
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

    // MARK: View Models
    private func getSignedInGoogleAccountRowViewModel() -> TappableRowView.ViewModel {
        TappableRowView.ViewModel(
                primaryText: .constant("Google Account"),
                secondaryText: .constant(viewModel.linkedGoogleAccountEmail),
                hasDisclosureIndicator: false
        )
    }

    private func getLogInWithGoogleButtonViewModel() -> RoundedButtonView.ViewModel {
        RoundedButtonView.ViewModel(
            text: "Log In With Google",
            textColor: self.viewModel.interactionDisabled ? Color.Theme.SecondaryText : Color.Theme.Primary
        ) {
            // Create the VC. On appear, dispatch an action to dismiss the placeholder view controller
            self.navigateToGoogleSignIn = true
        }
    }

    private func getUnlinkButtonViewModel() -> RoundedButtonView.ViewModel {
        RoundedButtonView.ViewModel(
            text: "Unlink Account",
            textColor: self.viewModel.interactionDisabled ? Color.Theme.SecondaryText : Color.Theme.Negative
        ) {
            self.showUnlinkConfirmationDialog.toggle()
        }
    }

}

struct AccountSettingsSection_Previews: PreviewProvider {

    private static let viewModel = AccountSettingsSection.ViewModel(
            linkedGoogleAccountEmail: "test@gmail.com",
            isSignedIn: true,
            showRestoreDialog: false,
            interactionDisabled: false
    )

    static var previews: some View {
        AccountSettingsSection(viewModel: viewModel)
            .background(Color.Theme.BackgroundPrimary)
            .environmentObject(PreviewRedux.initialStore)
    }
}
