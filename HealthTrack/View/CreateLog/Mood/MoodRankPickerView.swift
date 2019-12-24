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
        let moods: [MoodRank]
        @Binding var selectedMoodRank: Int
    }
    let viewModel: ViewModel
    
    var body: some View {
        HStack(spacing: CGFloat.Theme.Layout.normal) {
            Spacer()
            ForEach(0..<self.viewModel.moods.count) { index in
                Image(systemName: self.getImageNameForMood(for: self.viewModel.moods[index], isSelected: self.viewModel.selectedMoodRank == index))
                    .resizable()
                    .foregroundColor(self.viewModel.selectedMoodRank == index ? self.getSelectedIconColor(for: self.viewModel.moods[index]) : Color.Theme.grayscalePrimary)
                    .frame(width: CGFloat.Theme.Font.largeIcon, height: CGFloat.Theme.Font.largeIcon)
                    .padding(CGFloat.Theme.Layout.normal)
            }
            Spacer()
        }
    }
    
    private func getImageNameForMood(for moodRank: MoodRank, isSelected: Bool) -> String {
        switch moodRank {
        case .negative:
            return isSelected ? "1.circle.fill" : "1.circle"
        case .neutral:
            return isSelected ? "2.circle.fill" : "2.circle"
        case .positive:
            return isSelected ? "3.circle.fill" : "3.circle"
        }
    }
    
    private func getSelectedIconColor(for moodRank: MoodRank) -> Color {
        switch moodRank {
        case .negative:
            return Color.Theme.negative
        case .neutral:
            return Color.Theme.neutral
        case .positive:
            return Color.Theme.positive
        }
    }
    
}

struct MoodRankPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MoodRankPickerView(viewModel: MoodRankPickerView.ViewModel(
                moods: MoodRank.allCases,
                selectedMoodRank: .constant(0)
            ))
            MoodRankPickerView(viewModel: MoodRankPickerView.ViewModel(
                moods: MoodRank.allCases,
                selectedMoodRank: .constant(2)
            ))
            
            MoodRankPickerView(viewModel: MoodRankPickerView.ViewModel(
                moods: MoodRank.allCases,
                selectedMoodRank: .constant(1)
                )).environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
