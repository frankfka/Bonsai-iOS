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

    // TODO: Use indexed collection: https://swiftwithmajid.com/2019/12/04/must-have-swiftui-extensions/
    var body: some View {
        VStack {
            ForEach(viewModel.items, id: \.name) { itemViewModel in
                ListItemRow(viewModel: itemViewModel)
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
