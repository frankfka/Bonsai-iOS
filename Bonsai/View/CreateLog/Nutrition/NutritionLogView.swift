import SwiftUI

struct NutritionLogView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        @Binding var selectNutritionRowTitle: String

        init(selectNutritionRowTitle: Binding<String>) {
            self._selectNutritionRowTitle = selectNutritionRowTitle
        }
    }

    private var viewModel: ViewModel {
        getViewModel()
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
        return ViewModel(selectNutritionRowTitle: .constant(titleText))
    }

    func getNutritionItemAmountViewModel() -> CreateLogTextField.ViewModel {
        return CreateLogTextField.ViewModel(label: "Amount", input: Binding<String>(get: {
            self.store.state.createLog.nutrition.amount
        }, set: { newAmount in
            self.store.send(.createLog(action: .nutritionAmountDidChange(newAmount: newAmount)))
        }))
    }

}