
import SwiftUI
import Combine


// TODO: Hacky way to allow enough space when keyboard is shown, change when more support is added natively
// https://swiftwithmajid.com/2019/11/27/combine-and-swiftui-views/
struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
                NotificationCenter.default
                        .publisher(for: UIResponder.keyboardWillShowNotification)
                        .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                        .map { $0.height },
                NotificationCenter.default
                        .publisher(for: UIResponder.keyboardWillHideNotification)
                        .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
                .padding(.bottom, keyboardHeight)
                .onReceive(keyboardHeightPublisher) { self.keyboardHeight = $0 }
    }
}

extension View {
    func keyboardAwarePadding() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier())
    }
}
