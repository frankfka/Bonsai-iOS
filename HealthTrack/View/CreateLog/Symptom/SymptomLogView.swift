import SwiftUI

struct SymptomLogView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        @Binding var selectSymptomRowTitle: String

        init(selectSymptomRowTitle: Binding<String>) {
            self._selectSymptomRowTitle = selectSymptomRowTitle
        }
    }
    private var viewModel: ViewModel {
        getViewModel()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tappable Row for selecting a symptom
            NavigationLink(
                    destination: SearchListViewContainer(
                            onUpdateQueryDebounced: onUpdateQueryDebounced
                    )
                    .environmentObject(store)
            ) {
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: viewModel.$selectSymptomRowTitle,
                                secondaryText: .constant(""),
                                hasDisclosureIndicator: true
                        )
                )
            }
            Divider()
            SymptomSeveritySliderView(viewModel: getSymptomSeveritySliderViewModel())
        }
        .background(Color.Theme.backgroundSecondary)
    }

    // TODO: See if we can bundle this with the container view
    func onUpdateQueryDebounced(query: String) {
        store.send(.createLog(action: .searchQueryDidChange(query: query)))
    }

    func getViewModel() -> SymptomLogView.ViewModel {
        let symptomLogState = store.state.createLog.symptom
        let titleText = symptomLogState.selectedSymptom?.name ?? "Select a \(LogCategory.symptom.displayValue())"
        return ViewModel(selectSymptomRowTitle: .constant(titleText))
    }
    
    func getSymptomSeveritySliderViewModel() -> SymptomSeveritySliderView.ViewModel {
        let severity = store.state.createLog.symptom.severity
        let least = SymptomLog.Severity.least
        let most = SymptomLog.Severity.most
        return SymptomSeveritySliderView.ViewModel(
                severityString: severity.displayValue(),
                sliderRange: least.rawValue...most.rawValue,
                sliderValue: severity.rawValue,
                sliderStep: SymptomLog.Severity.increment,
                sliderValueChangeCallback: { newVal in
                    self.store.send(.createLog(action: .symptomSeverityDidChange(encodedValue: newVal)))
                }
        )
    }

}
