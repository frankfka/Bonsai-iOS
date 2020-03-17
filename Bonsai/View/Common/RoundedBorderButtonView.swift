//
//  RoundedBorderButtonView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-01-29.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct RoundedBorderButtonView: View {
    
    struct ViewModel {
        let text: String
        let textColor: Color
        let onTap: VoidCallback?
        
        init(text: String, textColor: Color = Color.Theme.grayscalePrimary, onTap: VoidCallback? = nil) {
            self.text = text
            self.textColor = textColor
            self.onTap = onTap
        }
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Button(action: {
            self.viewModel.onTap?()
        }) {
            Text(viewModel.text)
                .font(Font.Theme.normalText)
                .foregroundColor(viewModel.textColor)
                .padding(.horizontal, CGFloat.Theme.Layout.normal)
                .padding(.vertical, CGFloat.Theme.Layout.small)
        }
        .modifier(RoundedBorderSectionModifier())
    }
}

struct RoundedBorderButtonView_Previews: PreviewProvider {
    
    static private var viewModel = RoundedBorderButtonView.ViewModel(text: "Log This Again", textColor: Color.Theme.primary)
    
    static var previews: some View {
        RoundedBorderButtonView(viewModel: viewModel)
            .background(Color.Theme.grayscalePrimary)
            .previewLayout(.sizeThatFits)
    }
}
