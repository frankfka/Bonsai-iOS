//
// Created by Frank Jia on 2020-04-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// Segmented picker at the top to select between "By Date" and "All" view types
struct ViewLogsViewTypePickerView: View {

    struct ViewModel {
        static let buttonPadding: CGFloat = 2
        static let viewByDateDisplay: String = "By Date"
        static let viewAllDisplay: String = "All"
        @Binding var isViewByDate: Bool

        init(isViewByDate: Bool, onNewViewByDateChangedValue: BoolCallback? = nil) {
            self._isViewByDate = Binding<Bool>(get: {
                isViewByDate
            }, set: { newVal in
                onNewViewByDateChangedValue?(newVal)
            })
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            getButton(text: ViewModel.viewByDateDisplay, isActive: viewModel.isViewByDate) {
                self.isViewByDateChanged(newVal: true)
            }
            getButton(text: ViewModel.viewAllDisplay, isActive: !viewModel.isViewByDate) {
                self.isViewByDateChanged(newVal: false)
            }
        }
        .padding(ViewModel.buttonPadding)
        .background(
            RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.cornerRadius)
                .foregroundColor(Color.Theme.backgroundPrimary)
        )
    }

    private func getButton(text: String, isActive: Bool, onTap: VoidCallback?) -> AnyView {
        return Button(action: {
            onTap?()
        }, label: {
            Text(text)
                .font(Font.Theme.subtext)
                .foregroundColor(Color.Theme.textDark)
                .padding(CGFloat.Theme.Layout.small)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(
                    isActive ?
                        RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.cornerRadius)
                                .foregroundColor(Color.Theme.backgroundSecondary).eraseToAnyView()
                        : EmptyView().eraseToAnyView()
                )
        }).eraseToAnyView()
    }

    private func isViewByDateChanged(newVal: Bool) {
        if newVal != self.viewModel.isViewByDate {
            ViewHelpers.setWithLinearAnimation(binding: self.viewModel.$isViewByDate, newVal: newVal)
        }
    }

}


struct ViewLogsViewTypePickerView_Previews: PreviewProvider {
    static private var viewModel = ViewLogsViewTypePickerView.ViewModel(isViewByDate: true)
    
    static var previews: some View {
        ViewLogsViewTypePickerView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
