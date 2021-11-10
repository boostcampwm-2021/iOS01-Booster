import UIKit
import MapKit

class PhotoAnnotationView: UIView {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var photoImageView: UIImageView!

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        drawTriBackground()
    }

    private func drawTriBackground() {
        let path = UIBezierPath()
        path.lineWidth = 2

        let point1 = CGPoint(x: backgroundView.frame.midX, y: self.frame.height)
        let point2 = CGPoint(x: backgroundView.frame.minX + (backgroundView.frame.width / 3.0), y: backgroundView.frame.maxY - 2)
        let point3 = CGPoint(x: backgroundView.frame.maxX - (backgroundView.frame.width / 3.0), y: backgroundView.frame.maxY - 2)

        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.close()
        UIColor(red: 255/255, green: 92/255, blue: 0/255, alpha: 1).set()
        path.stroke()
        path.fill()
    }
}
