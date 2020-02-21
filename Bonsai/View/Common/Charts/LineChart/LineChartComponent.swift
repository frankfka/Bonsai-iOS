import SwiftUI

struct LineChartComponent: ChartComponent {
    
    private let data: LineChartData
    private let style: LineChartStyle
    private let marker: AnyView?
    
    init(data: LineChartData, style: LineChartStyle = LineChartStyle(), marker: AnyView? = nil) {
        self.data = data
        self.style = style
        self.marker = marker
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Stroke path
                self.getPath(
                    for: self.data.dataPoints,
                    with: self.style,
                    parentSize: geometry.size
                )
                    .stroke(self.style.lineColor, style: self.style.lineStrokeStyle)
                // Draw marker for each data point
                ForEach(self.data.dataPoints) { dataPoint in
                    self.getMarker(for: dataPoint)
                        .position(self.getPoint(for: dataPoint, parentSize: geometry.size))
                }
            }
        }
    }
    
    private func getPath(for dataPoints: [LineChartDataPoint], with style: LineChartStyle, parentSize: CGSize) -> Path {
        var path = Path()
        // Invalid if we have fewer than 2 points
        if (dataPoints.count < 2) {
            return path
        }
        var currPoint = getPoint(for: dataPoints[0], parentSize: parentSize)
        path.move(to: currPoint)
        // Connect the points
        for index in 1..<dataPoints.count {
            let nextPoint = getPoint(for: dataPoints[index], parentSize: parentSize)
            if style.smoothed {
                let mid = CGPoint.getMidpoint(between: currPoint, and: nextPoint)
                path.addQuadCurve(to: mid, control: CGPoint.getControlPoint(p1: mid, p2: currPoint))
                path.addQuadCurve(to: nextPoint, control: CGPoint.getControlPoint(p1: mid, p2: nextPoint))
                currPoint = nextPoint
            } else {
                path.addLine(to: nextPoint)
            }
        }
        return path
    }
    
    private func getPoint(for dataPoint: LineChartDataPoint, parentSize: CGSize) -> CGPoint {
        return CGPoint(
            x: dataPoint.displayX * parentSize.width,
            y: dataPoint.displayY * parentSize.height
        )
    }
    
    private func getMarker(for dataPoint: LineChartDataPoint) -> AnyView {
        // Custom marker per data point takes precedence
        if let marker = dataPoint.marker {
            return marker
        } else if let marker = self.marker {
            return marker
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
    
}

struct LineChartComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            LineChartComponent(
                data: PreviewCharts.LineChartDynamicData,
                style: PreviewCharts.AppLineChartStyle,
                marker: PreviewCharts.LineChartMarker
            )
            .frame(width: 200, height: 200, alignment: .bottom)
            .previewLayout(.sizeThatFits)

            LineChartComponent(
                data: PreviewCharts.LineChartConstantData
            )
            .frame(width: 200, height: 200, alignment: .bottom)
            .previewLayout(.sizeThatFits)
            
            
            LineChartComponent(
                data: LineChartData(dataPoints: [])
            )
            .frame(width: 200, height: 200, alignment: .bottom)
            .previewLayout(.sizeThatFits)
        }
    }
}
