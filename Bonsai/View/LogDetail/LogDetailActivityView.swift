import SwiftUI

struct LogDetailActivityView: View {

    struct ViewModel {
        let name: String
        let duration: String

        init(name: String, duration: TimeInterval) {
            self.name = name
            self.duration = duration.hourMinuteDescription()
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TitledSection(sectionTitle: "Activity") {
            VStack(spacing: 0) {
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Name"),
                                secondaryText: .constant(self.viewModel.name),
                                hasDisclosureIndicator: false
                        )
                )
                Divider()
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Duration"),
                                secondaryText: .constant(self.viewModel.duration),
                                hasDisclosureIndicator: false
                        )
                )
            }
        }
    }
}

struct LogDetailActivityView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailActivityView(
                viewModel: LogDetailActivityView.ViewModel(name: "Running", duration: TimeInterval(3900))
        )
        .previewLayout(.sizeThatFits)
    }
}
