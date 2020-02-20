import SwiftUI

struct BarChartComponent: View {
    let values: [Double] = [10, 20, 50, 20, 3, 20]
    let maxValue: Double = 60.0
    let barSpacing: CGFloat = 5
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: self.barSpacing) {
                ForEach(self.values, id: \.self) { value in
                    BarView(
                        relativeValue: CGFloat(value/self.maxValue)
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
    }
}

struct BarView: View {
    // TODO: static gradient: https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    
    let relativeValue: CGFloat
    let cornerRadius: CGFloat
    let fillColor: Color
    let fillGradientColors: [Color]?  // From top to bottom
    private var barFillGradient: LinearGradient {
        let gradientColors = fillGradientColors ?? [fillColor, fillColor]
        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    init(relativeValue: CGFloat, cornerRadius: CGFloat = CGFloat.Theme.Layout.cornerRadius,
         fillColor: Color = Color.Theme.primary, fillGradientColors: [Color]? = nil) {
        self.relativeValue = relativeValue
        self.fillColor = fillColor
        self.fillGradientColors = fillGradientColors
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Create a frame so we can align bars to the bottom
            HStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .fill(self.barFillGradient)
                    // Make this bar height = total height * relative value
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * self.relativeValue,
                        alignment: .bottom
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartComponent()
            .frame(width: 200, height: 200, alignment: .bottom)
            .previewLayout(.sizeThatFits)
    }
}
