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
        @Binding var showCreateLogModal: Bool
        
        init(tabIndex: Binding<Int>, showCreateLogModal: Binding<Bool>) {
            self._tabIndex = tabIndex
            self._showCreateLogModal = showCreateLogModal
        }
    }
    let viewModel: ViewModel
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Image(systemName: viewModel.tabIndex == 0 ? "house.fill" : "house")
                    .resizable()
                    .foregroundColor(viewModel.tabIndex == 0 ? Color.Theme.primary : Color.Theme.grayscalePrimary)
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat.Theme.Layout.normal)
                    .frame(height: CGFloat.Theme.Layout.tabItemHeight)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.viewModel.tabIndex = 0
                }
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: CGFloat.Theme.Layout.tabItemHeight)
                    .foregroundColor(Color.Theme.primary)
                    .onTapGesture {
                        self.viewModel.showCreateLogModal.toggle()
                }
                Image(systemName: viewModel.tabIndex == 1 ? "chart.bar.fill" : "chart.bar")
                    .resizable()
                    .foregroundColor(viewModel.tabIndex == 1 ? Color.Theme.primary : Color.Theme.grayscalePrimary)
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat.Theme.Layout.normal)
                    .frame(height: CGFloat.Theme.Layout.tabItemHeight)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.viewModel.tabIndex = 1
                }
            }
            .padding(.all, CGFloat.Theme.Layout.small)
        }
        .padding(.bottom, CGFloat.Theme.Layout.normal)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.Theme.backgroundSecondary)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            TabBarView(viewModel: TabBarView.ViewModel(tabIndex: .constant(0), showCreateLogModal: .constant(true)))
        }
    }
}
