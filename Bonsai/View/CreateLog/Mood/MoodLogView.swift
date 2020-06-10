import SwiftUI

struct MoodLogView: View {

    @EnvironmentObject var store: AppStore
    struct ViewModel {

    }
    private var viewModel: ViewModel {
        getViewModel()
    }

    var body: some View {
        VStack(spacing: CGFloat.Theme.Layout.Normal) {
            VStack(alignment: .center) {
                Text("How are you feeling?")
                    .font(Font.Theme.NormalBoldText)
                MoodRankPickerView(
                    viewModel: self.getMoodRankPickerViewModel()
                )
            }
            .padding(.top, CGFloat.Theme.Layout.Normal)
            .padding(.vertical, CGFloat.Theme.Layout.Normal)
            .background(Color.Theme.BackgroundSecondary)
        }
    }

    private func getViewModel() -> MoodLogView.ViewModel {
        return MoodLogView.ViewModel()
    }

    private func getMoodRankPickerViewModel() -> MoodRankPickerView.ViewModel {
        return MoodRankPickerView.ViewModel(
                moodRanks: store.state.createLog.mood.allMoodRanks,
                selectedMoodRankIndex: store.state.createLog.mood.selectedMoodRankIndex,
                onMoodRankTap: onMoodRankSelect
        )
    }

    private func onMoodRankSelect(index: Int) {
        store.send(.createLog(action: .moodRankSelected(selectedIndex: index)))
    }

}

//struct MoodLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            MoodLogView()
//        }
//        .background(Color.Theme.backgroundPrimary)
//        .previewLayout(.sizeThatFits)
//    }
//}
