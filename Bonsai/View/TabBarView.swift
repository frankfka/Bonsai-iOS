//
//  TabBarView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct TabBarView: View {
    
    struct ViewModel {
        @Binding var tabIndex: Int
        let onCreateLogPressed: VoidCallback?
        let onTabPressed: IntCallback?
        
        init(tabIndex: Binding<Int>, onCreateLogPressed: VoidCallback? = nil, onTabPressed: IntCallback? = nil) {
            self._tabIndex = tabIndex
            self.onCreateLogPressed = onCreateLogPressed
            self.onTabPressed = onTabPressed
        }
    }
    let viewModel: ViewModel
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Image(systemName: viewModel.tabIndex == 0 ? "house.fill" : "house")
                    .resizable()
                    .foregroundColor(viewModel.tabIndex == 0 ? Color.Theme.Primary : Color.Theme.GrayscalePrimary)
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat.Theme.Layout.Normal)
                    .frame(height: CGFloat.Theme.Layout.TabItemHeight)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.onTabPressed(index: 0)
                }
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: CGFloat.Theme.Layout.TabItemHeight)
                    .foregroundColor(Color.Theme.Primary)
                    .onTapGesture {
                        self.viewModel.onCreateLogPressed?()
                    }
                Image(systemName: viewModel.tabIndex == 1 ? "chart.bar.fill" : "chart.bar")
                    .resizable()
                    .foregroundColor(viewModel.tabIndex == 1 ? Color.Theme.Primary : Color.Theme.GrayscalePrimary)
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat.Theme.Layout.Normal)
                    .frame(height: CGFloat.Theme.Layout.TabItemHeight)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.onTabPressed(index: 1)
                }
            }
            .padding(.all, CGFloat.Theme.Layout.Small)
        }
        .padding(.bottom, CGFloat.Theme.Layout.Normal)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.Theme.BackgroundSecondary)
    }

    private func onTabPressed(index: Int) {
        self.viewModel.tabIndex = index
        self.viewModel.onTabPressed?(index)
    }

}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            TabBarView(viewModel: TabBarView.ViewModel(tabIndex: .constant(0)))
        }
    }
}
