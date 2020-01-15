//
//  LogDetailNotesView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-01-15.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogDetailNotesView: View {
    
    struct ViewModel {
        let notes: String
        var showNoNotesPlaceholder: Bool { notes.isEmptyWithoutWhitespace() }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        TitledSection(sectionTitle: "Notes") {
            HStack {
                Text(self.viewModel.showNoNotesPlaceholder ?  "No Notes" : self.viewModel.notes)
                        .font(Font.Theme.normalText)
                        .foregroundColor(Color.Theme.text)
                        .multilineTextAlignment(.leading)
                // Push text to leading
                Spacer(minLength: 0)
            }
            .padding(.all, CGFloat.Theme.Layout.normal)
            .background(Color.Theme.backgroundSecondary)
        }
    }
}

struct LogDetailNotesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogDetailNotesView(
                viewModel: LogDetailNotesView.ViewModel(notes: "Very very long string to demonstrate wrapping very very. Very very long string to demonstrate wrapping very very. Very very long string to demonstrate wrapping very very. Very very long string to demonstrate wrapping very very.")
            )
            LogDetailNotesView(
                viewModel: LogDetailNotesView.ViewModel(notes: "Short note")
            )
            LogDetailNotesView(
                viewModel: LogDetailNotesView.ViewModel(notes: "")
            )
        }
        .background(Color.Theme.backgroundPrimary)
        .previewLayout(.sizeThatFits)
    }
}
