//
//  CreateLogTextField.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-21.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct CreateLogTextField: View {

    struct ViewModel {
        let label: String
        @Binding var input: String
        let onIsEditingChanged: BoolCallback?
        let onTextCommit: VoidCallback?

        init(label: String, input: Binding<String>, onIsEditingChanged: BoolCallback? = nil, onTextCommit: VoidCallback? = nil) {
            self.label = label
            self._input = input
            self.onIsEditingChanged = onIsEditingChanged
            self.onTextCommit = onTextCommit
        }
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        UITextField.appearance().tintColor = Color.Theme.PrimaryUIColor
    }

    var body: some View {
        TextField(
            viewModel.label,
            text: viewModel.$input,
            onEditingChanged: viewModel.onIsEditingChanged ?? { _ in },
            onCommit: viewModel.onTextCommit ?? {}
        )
        .textFieldStyle(DefaultTextFieldStyle())
        .font(Font.Theme.NormalText)
        .padding(CGFloat.Theme.Layout.Normal)
        .background(Color.Theme.BackgroundSecondary)
    }
}

struct CreateLogTextField_Previews: PreviewProvider {
    static var previews: some View {
        CreateLogTextField(viewModel: CreateLogTextField.ViewModel(label: "Notes", input: .constant("")))
    }
}
