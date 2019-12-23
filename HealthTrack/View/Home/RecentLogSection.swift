//
//  RecentLogSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct RecentLogSection: View {
    
    struct ViewModel {
        let logs: [RecentLogRow.ViewModel]
    }
    
    let viewModel: ViewModel = ViewModel(logs:[
        RecentLogRow.ViewModel(name: "Vitamin D", category: "Nutrition", categoryColor: Color.Theme.negative, time: "9:00AM"),
        RecentLogRow.ViewModel(name: "Vitamin D", category: "Nutrition", categoryColor: Color.Theme.negative, time: "9:00AM"),
        RecentLogRow.ViewModel(name: "Vitamin D", category: "Nutrition", categoryColor: Color.Theme.negative, time: "9:00AM")
    ])
    
    var body: some View {
        VStack {
            ForEach(viewModel.logs) { log in
                RecentLogRow(viewModel: log)
            }
        }
    }
}

struct RecentLogSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecentLogSection()
        }.previewLayout(.sizeThatFits)
    }
}
