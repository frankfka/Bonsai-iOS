import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        let googleSignIn: String?
    }
    private var viewModel: ViewModel { getViewModel() }

    var body: some View {
        ScrollView {
            VStack {
                Text("Hello")
                Text(viewModel.googleSignIn ?? "Not Signed In")
                Button(action: {
                    // TODO open gooogle sign in
                }, label: {
                    Text("Sign In")
                })
            }
        }
    }

    private func getViewModel() -> ViewModel {
        let googleSignIn = store.state.global.user?.linkedFirebaseGoogleAccount
        return ViewModel(
            googleSignIn: googleSignIn
        )
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
