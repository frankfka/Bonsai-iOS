//
// Created by Frank Jia on 2020-04-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// Segmented picker at the top to select between "By Date" and "All" view types
struct ViewLogsViewTypePickerView: View {

    struct ViewModel {
        static let displayValues: [String] = ["By Date", "All"]
        @Binding var pickerSelection: Int

        init(isViewByDate: Bool, onNewViewByDateChangedValue: BoolCallback? = nil) {
            self._pickerSelection = Binding<Int>(get: {
                isViewByDate ? 0 : 1
            }, set: { newVal in
                onNewViewByDateChangedValue?(newVal == 0)
            })
        }
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            // TODO: Unfortunately we get weird flickering behavior on re-rendering, leaving for now
            Picker("", selection: self.viewModel.$pickerSelection) {
                ForEach(0..<ViewModel.displayValues.count) { index in
                    Text(ViewModel.displayValues[index]).tag(index)
                }
            }
                    .pickerStyle(SegmentedPickerStyle())
        }
                .padding(.vertical, CGFloat.Theme.Layout.small)
                .padding(.horizontal, CGFloat.Theme.Layout.normal)
                .background(Color.Theme.backgroundSecondary)
    }
}

