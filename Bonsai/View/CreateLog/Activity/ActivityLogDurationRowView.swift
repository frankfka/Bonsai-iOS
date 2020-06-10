import SwiftUI

extension TimeInterval {
    func hourMinuteDescription() -> String {
        var seconds: Int = Int(self.magnitude)
        let hours: Int
        let minutes: Int
        (hours, seconds) = seconds.quotientAndRemainder(dividingBy: 3600)
        minutes = seconds / 60
        return "\(hours) Hr, \(minutes) Min"
    }
}

struct ActivityLogDurationRowView: View {
    
    struct ViewModel {
        let didTapRow: VoidCallback
        let selectedDuration: TimeInterval?
        let onDurationChange: ActivityLogDurationPickerView.DurationCallback?
        var selectedDurationString: String {
            if let selectedDuration = self.selectedDuration {
                return selectedDuration.hourMinuteDescription()
            }
            return "Select Duration"
        }
        @Binding var showPicker: Bool
        
        init(
            selectedDuration: TimeInterval?,
            showPicker: Binding<Bool>,
            onDurationChange: ActivityLogDurationPickerView.DurationCallback? = nil
        ) {
            self.selectedDuration = selectedDuration
            self.didTapRow = {
                ViewHelpers.toggleWithEaseAnimation(binding: showPicker)
            }
            self.onDurationChange = onDurationChange
            self._showPicker = showPicker
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center) {
            TappableRowView(viewModel: TappableRowView.ViewModel(
                primaryText: .constant("Duration"),
                secondaryText: .constant(self.viewModel.selectedDurationString),
                hasDisclosureIndicator: false)
            )
            .onTapGesture {
                self.onRowTapped()
            }
            if self.viewModel.showPicker {
                ActivityLogDurationPickerView(viewModel: getDurationPickerViewModel())
            }
        }
        .background(Color.Theme.BackgroundSecondary)
    }
    
    private func onRowTapped() {
        ViewHelpers.toggleWithEaseAnimation(binding: viewModel.$showPicker)
    }

    private func getDurationPickerViewModel() -> ActivityLogDurationPickerView.ViewModel {
        return ActivityLogDurationPickerView.ViewModel(
                duration: viewModel.selectedDuration ?? TimeInterval(0),
                onDurationChange: viewModel.onDurationChange
        )
    }
    
}
