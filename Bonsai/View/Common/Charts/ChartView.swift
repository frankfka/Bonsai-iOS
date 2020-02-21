//
//  ChartView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-02-20.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct ChartView<Content>: View where Content: View {
    let components: () -> Content

    init(@ViewBuilder chartComponents: @escaping () -> Content) {
        self.components = chartComponents
    }

    var body: some View {
        ZStack {
            components()
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView {
            BarChartComponent(
                data: PreviewCharts.BarChartData,
                style: PreviewCharts.AppBarChartStyle
            )
            LineChartComponent(
                data: PreviewCharts.LineChartDynamicData,
                style: PreviewCharts.AppLineChartStyle
            )
        }
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
