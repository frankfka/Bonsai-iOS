//
//  RecentLogRow.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct RecentLogRow: View {
    
    struct ViewModel: Identifiable {
        let name: String
        let category: String
        let categoryColor: Color
        let time: String
        
        internal let id = UUID()
    }
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .font(Font.Theme.normalText)
                    .foregroundColor(Color.Theme.textDark)
                Text(viewModel.category)
                    .font(Font.Theme.subtext)
                    .foregroundColor(viewModel.categoryColor)
            }
            Spacer()
            Text(viewModel.time)
                .font(Font.Theme.subtext)
                .foregroundColor(Color.Theme.primary)
        }
        .padding(.vertical, CGFloat.Theme.Layout.small)
        .padding(.horizontal, CGFloat.Theme.Layout.normal)
    }
}

struct RecentLogRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecentLogRow(viewModel: RecentLogRow.ViewModel(name: "Vitamin D", category: "Nutrition", categoryColor: Color.Theme.negative, time: "9:00AM"))
        }.previewLayout(.sizeThatFits)
    }
}
