import SwiftUI

struct BarChartComponent: ChartComponent {
    let data: [BarChartDataPoint]
    let style: BarChartStyle
    
    init(data: [BarChartDataPoint], style: BarChartStyle = BarChartStyle()) {
        self.data = data.filter { data in data.isValid }
        self.style = style
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: self.style.barSpacing) {
                ForEach(self.data) { dataPoint in
                    BarView(
                        relativeValue: dataPoint.relativeValue,
                        cornerRadius: self.style.barRadius,
                        gradientColors: self.getBarGradientColors(for: dataPoint)
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
    }
    
    private func getBarGradientColors(for dataPoint: BarChartDataPoint) -> [Color] {
        return dataPoint.barGradientColors ?? style.barGradientColors
    }
    
}

struct BarView: View {
    let relativeValue: CGFloat
    let cornerRadius: CGFloat
    let fillGradientColors: [Color]  // Shown from top to bottom
    private var fillGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: fillGradientColors), startPoint: .top, endPoint: .bottom)
    }
    
    init(relativeValue: CGFloat, cornerRadius: CGFloat, gradientColors: [Color]) {
        self.relativeValue = relativeValue
        self.fillGradientColors = gradientColors
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: self.cornerRadius)
                // Make this bar height = total height * relative value
                .size(width: geometry.size.width, height: geometry.size.height * self.relativeValue)
                .rotation(.init(degrees: 180))
                .fill(self.fillGradient)
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    
    static var previews: some View {
        BarChartComponent(
            data: PreviewCharts.BarChartData,
            style: PreviewCharts.AppBarChartStyle
        )
        .frame(width: 200, height: 200, alignment: .bottom)
        .previewLayout(.sizeThatFits)
    }
}
