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

        init(label: String, input: Binding<String>) {
            self.label = label
            self._input = input
        }
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        UITextField.appearance().tintColor = Color.Theme.primaryUIColor
    }

    var body: some View {
        TextField(viewModel.label, text: viewModel.$input)
                .textFieldStyle(DefaultTextFieldStyle())
                .font(Font.Theme.normalText)
                .padding(CGFloat.Theme.Layout.normal)
                .background(Color.Theme.backgroundSecondary)
    }
}

struct CreateLogTextField_Previews: PreviewProvider {
    static var previews: some View {
        CreateLogTextField(viewModel: CreateLogTextField.ViewModel(label: "Notes", input: .constant("")))
    }
}
