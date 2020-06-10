//
// Created by Frank Jia on 2020-04-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct ViewLogsLoadMoreView: View {

    struct ViewModel {
        let showLoadingMoreIndicator: Bool
        let showLoadMoreButton: Bool
        let onShowMoreTapped: VoidCallback?

        init(showLoadingMoreIndicator: Bool, showLoadMoreButton: Bool, onShowMoreTapped: VoidCallback? = nil) {
            self.showLoadMoreButton = showLoadMoreButton
            self.showLoadingMoreIndicator = showLoadingMoreIndicator
            self.onShowMoreTapped = onShowMoreTapped
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center) {
            if viewModel.showLoadingMoreIndicator {
                FullWidthLoadingSpinner(size: .small)
            }
            if viewModel.showLoadMoreButton {
                // Load more button
                Button(action: {
                    self.viewModel.onShowMoreTapped?()
                }, label: {
                    Text("Show More")
                        .font(Font.Theme.NormalText)
                        .foregroundColor(Color.Theme.Primary)
                })
            }
        }
        .padding(.vertical, CGFloat.Theme.Layout.ExtraSmall)
        .padding(.horizontal, CGFloat.Theme.Layout.Normal)
        .frame(minWidth: 0, maxWidth: .infinity)
    }

}