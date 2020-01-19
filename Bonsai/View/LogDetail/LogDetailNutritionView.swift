import SwiftUI

struct LogDetailNutritionView: View {

    struct ViewModel {
        let name: String
        let amount: String
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TitledSection(sectionTitle: "Nutrition") {
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
                                primaryText: .constant("Amount"),
                                secondaryText: .constant(self.viewModel.amount),
                                hasDisclosureIndicator: false
                        )
                )
            }
        }
    }
}

struct LogDetailNutritionView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailNutritionView(
                viewModel: LogDetailNutritionView.ViewModel(name: "Creatine", amount: "1 Teaspoon")
        )
        .previewLayout(.sizeThatFits)
    }
}
