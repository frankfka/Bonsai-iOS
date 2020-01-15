//
//  LogDetailItemView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-01-14.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogDetailItemView: View {

    struct ViewModel {
        let title: String
        let value: String
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            Text(viewModel.title)
                .font(Font.Theme.boldNormalText)
                .foregroundColor(Color.Theme.textDark)
            Spacer()
            Text(viewModel.value)
                .font(Font.Theme.normalText)
                .foregroundColor(Color.Theme.text)
        }
        .padding(.horizontal, CGFloat.Theme.Layout.normal)
        .padding(.vertical, CGFloat.Theme.Layout.small)
    }
}

struct LogDetailItemView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailItemView(viewModel: LogDetailItemView.ViewModel(title: "Title", value: "Value"))
    }
}
