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
    @State(initialValue: false) private var showDurationPicker

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
            Divider()
            ActivityLogDurationRowView(viewModel: getActivityDurationRowViewModel())
        }
        .background(Color.Theme.backgroundSecondary)
    }

    private func onUpdateQueryDebounced(query: String) {
        store.send(.createLog(action: .searchQueryDidChange(query: query)))
    }

    private func getViewModel() -> ActivityLogView.ViewModel {
        let activityLogState = store.state.createLog.activity
        let titleText = activityLogState.selectedActivity?.name ?? "Select an \(LogCategory.activity.displayValue())"
        return ViewModel(selectActivityRowTitle: .constant(titleText))
    }

    private func getActivityDurationRowViewModel() -> ActivityLogDurationRowView.ViewModel {
        return ActivityLogDurationRowView.ViewModel(
                selectedDuration: store.state.createLog.activity.duration,
                showPicker: self.$showDurationPicker,
                onDurationChange: onDurationChange
        )
    }

    private func onDurationChange(newDuration: TimeInterval) {
        store.send(.createLog(action: .activityDurationDidChange(newDuration: newDuration)))
    }
}
