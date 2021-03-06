//
//  MoodRankView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-17.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct MoodRankPickerView: View {
    
    struct ViewModel {
        let moodRanks: [MoodRank]
        let selectedMoodRankIndex: Int?
        let onMoodRankTap: IntCallback?

        init(moodRanks: [MoodRank], selectedMoodRankIndex: Int? = nil, onMoodRankTap: IntCallback? = nil) {
            self.moodRanks = moodRanks
            self.selectedMoodRankIndex = selectedMoodRankIndex
            self.onMoodRankTap = onMoodRankTap
        }
    }
    let viewModel: ViewModel
    
    var body: some View {
        HStack(spacing: CGFloat.Theme.Layout.Normal) {
            Spacer()
            ForEach(0..<self.viewModel.moodRanks.count) { index in
                self.getImageForMood(for: self.viewModel.moodRanks[index], isSelected: self.viewModel.selectedMoodRankIndex == index)
                    .resizable()
                    .foregroundColor(self.getIconColor(for: index))
                    .frame(width: CGFloat.Theme.Font.LargeIcon, height: CGFloat.Theme.Font.LargeIcon)
                    .onTapGesture {
                        self.viewModel.onMoodRankTap?(index)
                    }
                    .padding(CGFloat.Theme.Layout.Normal)
            }
            Spacer()
        }
    }
    
    private func getImageForMood(for moodRank: MoodRank, isSelected: Bool) -> Image {
        switch moodRank {
        case .negative:
            return isSelected ? Image.Icons.OneCircleFill : Image.Icons.OneCircle
        case .neutral:
            return isSelected ? Image.Icons.TwoCircleFill : Image.Icons.TwoCircle
        case .positive:
            return isSelected ? Image.Icons.ThreeCircleFill : Image.Icons.ThreeCircle
        }
    }

    private func getIconColor(for index: Int) -> Color {
        return viewModel.selectedMoodRankIndex == index ?
                getSelectedIconColor(for: viewModel.moodRanks[index]) : Color.Theme.GrayscalePrimary
    }
    
    private func getSelectedIconColor(for moodRank: MoodRank) -> Color {
        switch moodRank {
        case .negative:
            return Color.Theme.Negative
        case .neutral:
            return Color.Theme.Neutral
        case .positive:
            return Color.Theme.Positive
        }
    }
    
}

struct MoodRankPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MoodRankPickerView(viewModel: MoodRankPickerView.ViewModel(
                moodRanks: MoodRank.allCases,
                selectedMoodRankIndex: 0
            ))
            MoodRankPickerView(viewModel: MoodRankPickerView.ViewModel(
                moodRanks: MoodRank.allCases,
                selectedMoodRankIndex: 2
            ))
            
            MoodRankPickerView(viewModel: MoodRankPickerView.ViewModel(
                moodRanks: MoodRank.allCases,
                selectedMoodRankIndex: 1
                )).environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
