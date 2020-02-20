import SwiftUI

struct LineChartComponent: View {

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

    static var circleMarker: AnyView = Circle()
            .foregroundColor(Color.Theme.neutral)
            .frame(width: 4, height: 4)
            .eraseToAnyView()

    static var dynamicData: LineChartData = LineChartData(
            dataPoints: [
                LineChartDataPoint(xRel: 0, yRel: 0.1, marker: circleMarker),
                LineChartDataPoint(xRel: 0.2, yRel: 0.4),
                LineChartDataPoint(xRel: 0.4, yRel: 0.6),
                LineChartDataPoint(xRel: 0.6, yRel: 0.2, marker: circleMarker),
                LineChartDataPoint(xRel: 0.8, yRel: 1),
                LineChartDataPoint(xRel: 1, yRel: 0.4)
            ]
    )

    static var constantData: LineChartData = LineChartData(
            dataPoints: [
                LineChartDataPoint(xRel: 0, yRel: 0.5),
                LineChartDataPoint(xRel: 1, yRel: 0.5)
            ]
    )

    static var appLineChartStyle: LineChartStyle = LineChartStyle(
        lineColor: Color.Theme.primary,
        lineStrokeStyle: StrokeStyle(),
        smoothed: true
    )
    
    static var previews: some View {
        Group {
            LineChartComponent(
                    data: dynamicData,
                    style: appLineChartStyle
            )
            .frame(width: 200, height: 200, alignment: .bottom)
            .previewLayout(.sizeThatFits)

            LineChartComponent(
                    data: constantData,
                    style: appLineChartStyle
            )
            .frame(width: 200, height: 200, alignment: .bottom)
            .previewLayout(.sizeThatFits)
        }
    }
}
