import UIKit
import MapKit

class PhotoAnnotationView: MKAnnotationView {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!

    private var pathColor: UIColor = .boosterOrange

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        drawTriBackground(color: self.pathColor)
    }

    private func drawTriBackground(color: UIColor) {
        let path = UIBezierPath()
        path.lineWidth = 2

        let point1 = CGPoint(x: backgroundView.frame.midX, y: self.frame.height)
        let point2 = CGPoint(x: backgroundView.frame.minX + (backgroundView.frame.width / 3.0), y: backgroundView.frame.maxY - 2)
        let point3 = CGPoint(x: backgroundView.frame.maxX - (backgroundView.frame.width / 3.0), y: backgroundView.frame.maxY - 2)

        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.close()
        color.set()
        path.stroke()
        path.fill()

        backgroundView.backgroundColor = color
    }

    func changeColor(_ color: UIColor) {
        pathColor = color
    }
}
