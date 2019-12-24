////
////  MoodLogView.swift
////  HealthTrack
////
////  Created by Frank Jia on 2019-12-16.
////  Copyright © 2019 Frank Jia. All rights reserved.
////
//
//import SwiftUI
//
//struct MoodLogView: View {
//    @Binding var query: String
//    @Binding var results: [Searchable]
//
//    var body: some View {
//        VStack(spacing: CGFloat.Theme.Layout.normal) {
//            VStack(alignment: .center) {
//                Text("How are you feeling?")
//                    .font(Font.Theme.boldNormalText)
//                MoodRankPickerView(
//                    viewModel: MoodRankPickerView.ViewModel(
//                        moods: MoodRank.allCases,
//                        selectedMoodRank: .constant(2)
//                    )
//                )
//            }
//            .padding(.top, CGFloat.Theme.Layout.normal)
//            .padding(.vertical, CGFloat.Theme.Layout.normal)
//            .background(Color.Theme.backgroundSecondary)
//            NavigationLink(
//                destination: SearchListView(
//                    query: self._query,
//                    results: self._results
//                )
//            ) {
//                TappableRowView(
//                    viewModel: TappableRowView.ViewModel(
//                        primaryText: .constant("Feelings"),
//                        secondaryText: .constant("Happy, Excited, Anxious"),
//                        hasDisclosureIndicator: true)
//                )
//            }
//            .background(Color.Theme.backgroundSecondary)
//        }
//    }
//}
//
////struct MoodLogView_Previews: PreviewProvider {
////    static var previews: some View {
////        Group {
////            MoodLogView()
////        }
////        .background(Color.Theme.backgroundPrimary)
////        .previewLayout(.sizeThatFits)
////    }
////}
