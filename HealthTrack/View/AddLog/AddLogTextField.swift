//
//  AddLogTextField.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-21.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct AddLogTextField: View {

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
                .foregroundColor(Color.Theme.primary)
                .font(Font.Theme.normalText)
                .padding(CGFloat.Theme.Layout.normal)
                .background(Color.Theme.backgroundSecondary)
    }
}

struct AddLogTextField_Previews: PreviewProvider {
    static var previews: some View {
        AddLogTextField(viewModel: AddLogTextField.ViewModel(label: "Notes", input: .constant("")))
    }
}
