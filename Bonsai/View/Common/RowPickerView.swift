//
//  RowPickerView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-22.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

protocol RowPickerValue {
    var pickerDisplay: String { get }
}

struct RowPickerView: View {
    @State(initialValue: false) private var showPicker: Bool
    
    struct ViewModel {
        let rowTitle: String
        let rowValue: String
        let values: [RowPickerValue]
        let selectionIndex: Binding<Int>
    }
    private let viewModel: ViewModel
    private var rowViewModel: TappableRowView.ViewModel {
        TappableRowView.ViewModel(
            primaryText: .constant(viewModel.rowTitle),
            secondaryText: .constant(viewModel.rowValue),
            hasDisclosureIndicator: false
        )
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TappableRowView(viewModel: rowViewModel)
                .onTapGesture {
                    self.onRowTapped()
            }
            if self.showPicker {
                Picker(
                    selection: viewModel.selectionIndex,
                    label: Text("")
                ) {
                    ForEach(0 ..< self.viewModel.values.count) {
                        Text(self.viewModel.values[$0].pickerDisplay)
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
    
    private func onRowTapped() {
        ViewHelpers.toggleWithEaseAnimation(binding: self.$showPicker)
    }
}

struct RowPickerView_Previews: PreviewProvider {
    
    struct ExampleRowPickerValue: RowPickerValue {
        let pickerDisplay: String
    }
    
    static let viewModel = RowPickerView.ViewModel(
        rowTitle: "Example Title",
        rowValue: "Example Value",
        values: [
            ExampleRowPickerValue(pickerDisplay: "1"),
            ExampleRowPickerValue(pickerDisplay: "2"),
            ExampleRowPickerValue(pickerDisplay: "3")
        ],
        selectionIndex: .constant(1)
    )
    
    static var previews: some View {
        RowPickerView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
