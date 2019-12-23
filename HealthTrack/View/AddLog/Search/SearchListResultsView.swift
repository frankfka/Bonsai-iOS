//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct SearchResultsView: View {
    struct ViewModel {
        let items: [ListItemRow.ViewModel]
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ForEach(0..<viewModel.items.count) { index in
                ListItemRow(viewModel: self.viewModel.items[index])
                if index < self.viewModel.items.count - 1 {
                    // Show a divider
                    Divider()
                }
            }
        }
    }
}

struct SearchInfoView: View {
    struct ViewModel {
        let text: String
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Text(viewModel.text)
                    .font(Font.Theme.normalText)
                    .foregroundColor(Color.Theme.text)
                    .padding(CGFloat.Theme.Layout.normal)
            Spacer()
        }
    }
}