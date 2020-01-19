import SwiftUI

struct LogDetailMedicationView: View {

    struct ViewModel {
        let name: String
        let dosage: String
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TitledSection(sectionTitle: "Medication") {
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
                                primaryText: .constant("Dosage"),
                                secondaryText: .constant(self.viewModel.dosage),
                                hasDisclosureIndicator: false
                        )
                )
            }
        }
    }
}

struct LogDetailMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailMedicationView(
                viewModel: LogDetailMedicationView.ViewModel(name: "Advil", dosage: "1 Tablet")
        )
        .previewLayout(.sizeThatFits)
    }
}
