//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct AddNewListItemView: View {

    struct ViewModel {
        @Binding var text: String
        let onTap: VoidCallback?

        init(text: Binding<String>, onTap: VoidCallback?) {
            self._text = Binding<String>(get: {
                return "Add \(text.wrappedValue)"
            }, set: { newVal in
                text.wrappedValue = newVal
            })
            self.onTap = onTap
        }
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: CGFloat.Theme.Font.normalIcon, height: CGFloat.Theme.Font.normalIcon)
                    .foregroundColor(Color.Theme.primary)
                    .padding(.trailing, CGFloat.Theme.Layout.small)
            Text(viewModel.text)
                    .font(Font.Theme.normalText)
            Spacer()
        }
                .padding(.all, CGFloat.Theme.Layout.small)
                .onTapGesture {
                    self.viewModel.onTap?()
                }
    }
}
