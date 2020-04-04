import SwiftUI

struct LogDetailSymptomView: View {
    
    struct ViewModel {
        let name: String
        let severity: String
        let severityAnalytics: SymptomSeverityAnalytics?
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: CGFloat.Theme.Layout.normal) {
            // Symptom Details
            TitledSection(sectionTitle: "Symptom") {
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
                            primaryText: .constant("Severity"),
                            secondaryText: .constant(self.viewModel.severity),
                            hasDisclosureIndicator: false
                        )
                    )
                }
            }
            viewModel.severityAnalytics.map { analytics in
                RoundedBorderTitledSection(sectionTitle: "Past Severities") {
                    HistoricalSymptomSeverityView(
                        viewModel: HistoricalSymptomSeverityView.ViewModel(analytics: analytics)
                    )
                    .padding(CGFloat.Theme.Layout.small)
                }
                .padding(CGFloat.Theme.Layout.small)
            }
        }
    }
}

struct LogDetailSymptomView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailSymptomView(
            viewModel: LogDetailSymptomView.ViewModel(name: "Fatigue", severity: "Extreme", severityAnalytics: AnalyticsPreviews.HistoricalSeverityPastWeek)
        )
        .background(Color.Theme.backgroundPrimary)
        .previewLayout(.sizeThatFits)
    }
}
