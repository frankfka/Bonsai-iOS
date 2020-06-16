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

    // MARK: Child views
    private var homeTabButton: some View {
        getTabBarIcon(
            selectedImage: Image.Icons.HouseFill,
            defaultImage: Image.Icons.House,
            isSelected: viewModel.tabIndex == 0,
            onTap: { self.onTabPressed(index: 0) }
        )
    }
    private var allLogsTabButton: some View {
        getTabBarIcon(
            selectedImage: Image.Icons.ChartBarFill,
            defaultImage: Image.Icons.ChartBar,
            isSelected: viewModel.tabIndex == 1,
            onTap: { self.onTabPressed(index: 1) }
        )
    }
    private func getTabBarIcon(selectedImage: Image, defaultImage: Image, isSelected: Bool, onTap: @escaping VoidCallback) -> some View {
        (isSelected ? selectedImage : defaultImage)
            .resizable()
            .foregroundColor(isSelected ? Color.Theme.Primary : Color.Theme.GrayscalePrimary)
            .aspectRatio(contentMode: .fit)
            .padding(CGFloat.Theme.Layout.Normal)
            .frame(height: CGFloat.Theme.Layout.TabItemHeight)
            .frame(minWidth: 0, maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
    }
    private var createLogButton: some View {
        Image.Icons.PlusCircleFill
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: CGFloat.Theme.Layout.TabItemHeight)
            .foregroundColor(Color.Theme.Primary)
            .onTapGesture {
                self.viewModel.onCreateLogPressed?()
            }
    }

    // MARK: Main view
    var body: some View {
        VStack {
            Divider()
            HStack {
                self.homeTabButton
                self.createLogButton
                self.allLogsTabButton
            }
            .padding(.all, CGFloat.Theme.Layout.Small)
        }
        .padding(.bottom, CGFloat.Theme.Layout.Normal)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.Theme.BackgroundSecondary)
    }

    // MARK: Actions
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
