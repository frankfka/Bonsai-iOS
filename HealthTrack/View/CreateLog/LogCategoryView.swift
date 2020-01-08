//
//  PickCategoryView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogCategoryView: View {
    
    struct ViewModel {
        let categories: [String]
        let didTapView: VoidCallback
        @Binding var selectedCategory: Int
        @Binding var selectedCategoryString: String
        @Binding var showPicker: Bool
        
        init(
            categories: [String],
            selectedCategory: Int,
            selectedCategoryDidChange: @escaping (Int) -> (),
            showPicker: Binding<Bool>
        ) {
            
            self.categories = categories
            self._selectedCategory = Binding<Int>(get: {
                return selectedCategory
            }, set: { newVal in
                selectedCategoryDidChange(newVal)
                ViewHelpers.toggleWithAnimation(binding: showPicker)
            })
            self._selectedCategoryString = Binding<String>(get: {
                return categories[selectedCategory]
            }, set: { _ in })
            self._showPicker = showPicker
            self.didTapView = {
                ViewHelpers.toggleWithAnimation(binding: showPicker)
            }
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center) {
            TappableRowView(viewModel: TappableRowView.ViewModel(
                primaryText: .constant("Log Category"),
                secondaryText: viewModel.$selectedCategoryString,
                hasDisclosureIndicator: false)
            )
                .onTapGesture {
                    self.onRowTapped()
            }
            if self.viewModel.showPicker {
                Picker(
                    selection: viewModel.$selectedCategory,
                    label: Text("")
                ) {
                    ForEach(0 ..< self.viewModel.categories.count) {
                        Text(self.viewModel.categories[$0])
                            .tag($0)
                            .font(Font.Theme.normalText)
                            .foregroundColor(Color.Theme.textDark)
                    }
                }
                .labelsHidden()
                .padding(CGFloat.Theme.Layout.small)
            }
        }
        .background(Color.Theme.backgroundSecondary)
    }
    
    func onRowTapped() {
        ViewHelpers.toggleWithAnimation(binding: viewModel.$showPicker)
    }
    
}

struct LogCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        LogCategoryView(
            viewModel: LogCategoryView.ViewModel(
                categories: LogCategory.allCases.map{ $0.displayValue() },
                selectedCategory: 0,
                selectedCategoryDidChange: { _ in },
                showPicker: .constant(true)
            )
        )
            .previewLayout(.sizeThatFits)
        //            .environment(\.colorScheme, .dark)
    }
}
