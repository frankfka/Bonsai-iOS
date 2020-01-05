import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        @Binding var selectActivityRowTitle: String

        init(selectActivityRowTitle: Binding<String>) {
            self._selectActivityRowTitle = selectActivityRowTitle
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
                    .environmentObject(store)
            ) {
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: viewModel.$selectActivityRowTitle,
                                secondaryText: .constant(""),
                                hasDisclosureIndicator: true
                        )
                )
            }
        }
        .background(Color.Theme.backgroundSecondary)
    }

    // TODO: See if we can bundle this with the container view
    func onUpdateQueryDebounced(query: String) {
        store.send(.createLog(action: .searchQueryDidChange(query: query)))
    }

    func getViewModel() -> ActivityLogView.ViewModel {
        let activityLogState = store.state.createLog.activity
        let titleText = activityLogState.selectedActivity?.name ?? "Select an \(LogCategory.activity.displayValue())"
        return ViewModel(selectActivityRowTitle: .constant(titleText))
    }

}