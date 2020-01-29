import SwiftUI
import GoogleSignIn
import UIKit

struct AuthViewControllerRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var store: AppStore

    typealias UIViewControllerType = AuthViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<AuthViewControllerRepresentable>)
                    -> AuthViewController {
        // Show an empty view controller
        AuthViewController(store: store)
    }

    func updateUIViewController(_ uiViewController: AuthViewController, context: UIViewControllerRepresentableContext<AuthViewControllerRepresentable>) {

    }

    // An empty view controller that
    class AuthViewController: UIViewController {
        private let store: AppStore

        init(store: AppStore) {
            self.store = store
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            // On View appear, tell the store to begin the sign in flow
            store.send(.settings(action: .linkGoogleAccountPressed(presentingVc: self)))
        }
    }

}

