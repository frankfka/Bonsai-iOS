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
            ForEach(viewModel.items, id: \.name) { itemViewModel in
                Group {
                    ListItemRow(viewModel: itemViewModel)
                    if self.showDivider(after: itemViewModel) {
                        Divider()
                    }
                }
            }
        }
    }
    
    private func showDivider(after vm: ListItemRow.ViewModel) -> Bool {
        let index = viewModel.items.firstIndex { item in vm.name == item.name }
        if let index = index, index < viewModel.items.count - 1 {
            return true
        }
        return false
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
