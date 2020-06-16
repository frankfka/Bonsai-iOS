//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct AddNewListItemView: View {
    
    struct ViewModel {
        @Binding var text: String
        let onTap: VoidCallback?
        
        init(text: String, onTap: VoidCallback?) {
            self._text = Binding<String>(get: {
                return "Add \(text)"
            }, set: { _ in })
            self.onTap = onTap
        }
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Image.Icons.PlusCircleFill
                .resizable()
                .frame(width: CGFloat.Theme.Font.NormalIcon, height: CGFloat.Theme.Font.NormalIcon)
                .foregroundColor(Color.Theme.Primary)
                .padding(.trailing, CGFloat.Theme.Layout.Small)
            Text(viewModel.text)
                .font(Font.Theme.NormalText)
            Spacer()
        }
        .padding(.all, CGFloat.Theme.Layout.Small)
        .contentShape(Rectangle())
        .onTapGesture {
            self.viewModel.onTap?()
        }
    }
}
