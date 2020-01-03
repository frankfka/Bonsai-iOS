//import SwiftUI
//
//struct SymptomLogView: View {
//    @EnvironmentObject var store: AppStore
//
//    struct ViewModel {
//        @Binding var selectNutritionRowTitle: String
//
//        init(selectNutritionRowTitle: Binding<String>) {
//            self._selectNutritionRowTitle = selectNutritionRowTitle
//        }
//    }
//    private var viewModel: ViewModel {
//        getViewModel()
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            NavigationLink(
//                    destination: SearchListViewContainer(
//                            onUpdateQueryDebounced: onUpdateQueryDebounced
//                    )
//                    .environmentObject(store)
//            ) {
//                TappableRowView(
//                        viewModel: TappableRowView.ViewModel(
//                                primaryText: viewModel.$selectNutritionRowTitle,
//                                secondaryText: .constant(""),
//                                hasDisclosureIndicator: true
//                        )
//                )
//            }
//        }
//        .background(Color.Theme.backgroundSecondary)
//    }
//
//    // TODO: See if we can bundle this with the container view
//    func onUpdateQueryDebounced(query: String) {
//        store.send(.createLog(action: .searchQueryDidChange(query: query)))
//    }
//
//    func getViewModel() -> SymptomLogView.ViewModel {
//        let SymptomLogState = store.state.createLog.nutrition
//        let titleText = SymptomLogState.selectedItem?.name ?? "Select a Supplement/Nutrition Item"
//        return ViewModel(selectNutritionRowTitle: .constant(titleText))
//    }
//
//}