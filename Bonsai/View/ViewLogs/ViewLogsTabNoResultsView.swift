//
// Created by Frank Jia on 2020-04-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI


// Text to show no results
struct ViewLogsTabNoResultsView: View {

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No Logs Found")
                    .font(Font.Theme.Heading)
                    .foregroundColor(Color.Theme.Text)
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity)
    }

}