import SwiftUI

struct ToggleRowView: View {
    
    struct ViewModel {
        @Binding var title: String
        @Binding var description: String?
        @Binding var value: Bool

        init(title: Binding<String>, description: Binding<String?> = .constant(nil), value: Binding<Bool>) {
            self._title = title
            self._description = description
            self._value = value
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: CGFloat.Theme.Layout.Small) {
                Text(viewModel.title)
                    .lineLimit(1)
                    .font(Font.Theme.NormalBoldText)
                    .foregroundColor(Color.Theme.Text)
                viewModel.description.map {
                    Text($0)
                        .lineLimit(nil)
                        .font(Font.Theme.SmallText)
                        .foregroundColor(Color.Theme.SecondaryText)
                }
            }
            Spacer(minLength: CGFloat.Theme.Layout.Large)
            Toggle(isOn: viewModel.$value, label: { EmptyView() }).labelsHidden()
        }
        .foregroundColor(Color.Theme.Primary)
        .modifier(FormRowModifier())
    }
}

struct ToggleRowView_Previews: PreviewProvider {

    private static let titleOnlyVm = ToggleRowView.ViewModel(title: .constant("Test Label"), value: .constant(true))
    private static let titleWithLongDescriptionVm = ToggleRowView.ViewModel(
        title: .constant("Test Label"),
        description: .constant("This is a very very long description that says something cool"),
        value: .constant(false)
    )

    static var previews: some View {
        Group {
            ToggleRowView(viewModel: titleOnlyVm)
            ToggleRowView(viewModel: titleOnlyVm).environment(\.colorScheme, .dark)
            ToggleRowView(viewModel: titleWithLongDescriptionVm)
        }.previewLayout(.sizeThatFits)
    }
}
