//
//  TappableRowView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-16.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct TappableRowView: View {
    
    struct ViewModel {
        @Binding var primaryText: String
        @Binding var secondaryText: String
        let hasDisclosureIndicator: Bool

        init(primaryText: Binding<String>, secondaryText: Binding<String>, hasDisclosureIndicator: Bool) {
            self._primaryText = primaryText
            self._secondaryText = secondaryText
            self.hasDisclosureIndicator = hasDisclosureIndicator
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(viewModel.primaryText)
                .lineLimit(1)
                .font(Font.Theme.NormalBoldText)
                .foregroundColor(Color.Theme.Text)
            Spacer(minLength: CGFloat.Theme.Layout.RowSeparator)
            Text(viewModel.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(Font.Theme.NormalText)
                .foregroundColor(Color.Theme.SecondaryText)
            if viewModel.hasDisclosureIndicator {
                Image.Icons.ChevronRight
                    .foregroundColor(Color.Theme.TertiaryText)
                    .padding(.leading, CGFloat.Theme.Layout.Small)
            }
        }
        .modifier(FormRowModifier())
    }
}

struct TappableRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TappableRowView(viewModel: TappableRowView.ViewModel(
                primaryText: .constant("Category"),
                secondaryText: .constant("Note"),
                hasDisclosureIndicator: true)
            )
            TappableRowView(viewModel: TappableRowView.ViewModel(
                    primaryText: .constant("Category"),
                    secondaryText: .constant("Note Note Note Note Note Note Note"),
                    hasDisclosureIndicator: true)
            )
            TappableRowView(viewModel: TappableRowView.ViewModel(
                    primaryText: .constant("Category"),
                    secondaryText: .constant("Note"),
                    hasDisclosureIndicator: true)
            ).environment(\.colorScheme, .dark)
        }.previewLayout(.sizeThatFits)
    }
}
