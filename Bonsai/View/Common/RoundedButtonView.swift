//
//  RoundedButtonView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-01-29.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct RoundedButtonView: View {
    
    struct ViewModel {
        let text: String
        let textColor: Color
        let fillColor: Color
        let onTap: VoidCallback?
        
        init(
            text: String,
            textColor: Color = Color.Theme.GrayscalePrimary,
            fillColor: Color = Color.Theme.BackgroundSecondary,
            onTap: VoidCallback? = nil
        ) {
            self.text = text
            self.textColor = textColor
            self.fillColor = fillColor
            self.onTap = onTap
        }
    }
    
    private let viewModel: ViewModel
    
    init(vm: ViewModel) {
        self.viewModel = vm
    }
    
    var body: some View {
        Button(action: {
            self.viewModel.onTap?()
        }) {
            Text(viewModel.text)
                .font(Font.Theme.NormalText)
                .foregroundColor(viewModel.textColor)
                .padding(.horizontal, CGFloat.Theme.Layout.Normal)
                .padding(.vertical, CGFloat.Theme.Layout.Small)
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(.all, CGFloat.Theme.Layout.Small)
        .background(viewModel.fillColor)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.CornerRadius))
    }
}

struct RoundedButtonView_Previews: PreviewProvider {
    
    static private var viewModel = RoundedButtonView.ViewModel(text: "Log This Again", textColor: Color.Theme.Primary)
    
    static var previews: some View {
        Group {
            RoundedButtonView(vm: viewModel)
                .previewLayout(.sizeThatFits)
        }
        .padding()
        .background(Color.gray)
    }
}
