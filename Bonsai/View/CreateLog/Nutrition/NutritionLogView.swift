import SwiftUI

struct NutritionLogView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        @Binding var selectNutritionRowTitle: String
        @Binding var nutritionAmountText: String

        init(selectNutritionRowTitleBinding: Binding<String>,
             nutritionAmountTextBinding: Binding<String>) {
            self._selectNutritionRowTitle = selectNutritionRowTitleBinding
            self._nutritionAmountText = nutritionAmountTextBinding
        }
    }

    @Binding private var nutritionAmountText: String
    private var viewModel: ViewModel {
        getViewModel()
    }

    init(nutritionAmountTextBinding: Binding<String>) {
        self._nutritionAmountText = nutritionAmountTextBinding
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(
                destination: SearchListViewContainer(
                    onUpdateQueryDebounced: onUpdateQueryDebounced
                )
            ) {
                TappableRowView(
                    viewModel: TappableRowView.ViewModel(
                        primaryText: viewModel.$selectNutritionRowTitle,
                        secondaryText: .constant(""),
                        hasDisclosureIndicator: true
                    )
                )
            }
            Divider()
            CreateLogTextField(viewModel: getNutritionItemAmountViewModel())
        }
            .background(Color.Theme.BackgroundSecondary)
    }

    func onUpdateQueryDebounced(query: String) {
        store.send(.createLog(action: .searchQueryDidChange(query: query)))
    }

    func getViewModel() -> NutritionLogView.ViewModel {
        let nutritionLogState = store.state.createLog.nutrition
        let titleText = nutritionLogState.selectedItem?.name ?? "Select a \(LogCategory.nutrition.displayValue()) Item"
        return ViewModel(
            selectNutritionRowTitleBinding: .constant(titleText),
            nutritionAmountTextBinding: self._nutritionAmountText
        )
    }

    func getNutritionItemAmountViewModel() -> CreateLogTextField.ViewModel {
        return CreateLogTextField.ViewModel(label: "Amount", input: self.viewModel.$nutritionAmountText) {
            self.store.send(.createLog(action: .nutritionAmountDidChange(newAmount: self.viewModel.nutritionAmountText)))
        }
    }

}