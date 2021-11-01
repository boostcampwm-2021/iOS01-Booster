import MapKit

class CircleRenderer: MKCircleRenderer {
    override func fillPath(_ path: CGPath, in context: CGContext) {
        let rect: CGRect = path.boundingBox
        context.addPath(path)
        context.clip()

        let gradientLocations: [CGFloat]  = [0.8, 1.0]
        let gradientColors: [CGFloat] = [1.0, 0.332, 0.0, 0.1, 1.0, 1.0, 1.0, 0.1]
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: gradientColors, locations: gradientLocations, count: 2) else {
            return
        }

        let gradientCenter = CGPoint(x: rect.midX, y: rect.midY)
        let gradientRadius = min(rect.size.width, rect.size.height) / 2
        
        context.drawRadialGradient(gradient,
                                   startCenter: gradientCenter,
                                   startRadius: 0,
                                   endCenter: gradientCenter,
                                   endRadius: gradientRadius,
                                   options: .drawsAfterEndLocation)
    }
}
