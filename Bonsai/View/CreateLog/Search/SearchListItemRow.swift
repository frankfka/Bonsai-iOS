//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct ListItemRow: View {
    
    struct ViewModel {
        let name: String
        let onTap: VoidCallback?
        
        init(name: String, onTap: VoidCallback? = nil) {
            self.name = name
            self.onTap = onTap
        }
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(viewModel.name)
                .font(Font.Theme.NormalText)
            Spacer()
        }
        .padding(.all, CGFloat.Theme.Layout.Small)
        // Allow taps on Spacer
        .contentShape(Rectangle())
        .onTapGesture {
            self.viewModel.onTap?()
        }
    }
}

struct SearchListItemRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ListItemRow(viewModel: ListItemRow.ViewModel(name: "Advil"))
        }.previewLayout(.sizeThatFits)
    }
}
