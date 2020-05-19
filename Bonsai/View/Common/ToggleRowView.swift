import SwiftUI

struct ToggleRowView: View {
    
    struct ViewModel {
        @Binding var title: String
        @Binding var value: Bool

        init(title: Binding<String>, value: Binding<Bool>) {
            self._title = title
            self._value = value
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Toggle(isOn: viewModel.$value) {
            Text(viewModel.title)
                    .lineLimit(1)
                    .font(Font.Theme.normalBoldText)
                    .foregroundColor(Color.Theme.textDark)
        }
        .foregroundColor(Color.Theme.primary)
        .modifier(FormRowModifier())
    }
}

struct ToggleRowView_Previews: PreviewProvider {

    private static let viewModel: ToggleRowView.ViewModel = ToggleRowView.ViewModel(title: .constant("Test Label"), value: .constant(true))

    static var previews: some View {
        Group {
            ToggleRowView(viewModel: viewModel)
            ToggleRowView(viewModel: viewModel).environment(\.colorScheme, .dark)
        }.previewLayout(.sizeThatFits)
    }
}
