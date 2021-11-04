import UIKit

final class BarChartView: UIView {

    // MARK: - Variables

    private let graphView = UIView()

    private let dateLabel = UILabel()
    private let stepLabel = UILabel()

    private let graphLayer = CALayer()
    private let textLayer = CALayer()

    private let selectionLayer = CAShapeLayer()

    private var CGPoints: [CGPoint]?

    private var xOffset: CGFloat { self.frame.width / CGFloat(self.statisticsCollection.count) }
    private var barWidth: CGFloat { self.xOffset * 0.7 }
    private var barHalfWidth: CGFloat { self.barWidth / 2 }
    private var topSpace: CGFloat { self.frame.height * 0.2 }
    private var selectionSpace: CGFloat { self.frame.height * 0.15 }
    private var bottomSpace: CGFloat { self.frame.height * 0.15 }

    var statisticsCollection = StatisticsCollection() {
        didSet {
            self.setNeedsLayout()
        }
    }

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGesture()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        addGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGesture()
    }

    // MARK: - @objc

    @objc private func drawStatistics(_ sender: UIGestureRecognizer) {
        var tappedLocation: CGPoint = sender.location(in: self.graphView)
        let tappedGraphIndex: Int = Int(tappedLocation.x / self.xOffset)

        guard 0 <= tappedLocation.x && tappedLocation.x < self.frame.size.width,
              let point = CGPoints?[tappedGraphIndex] else { return }

        tappedLocation.x = CGFloat(tappedGraphIndex) * self.xOffset + self.xOffset / 2

        let oldX = self.selectionLayer.frame.origin.x

        if oldX == tappedLocation.x && selectionLayer.superlayer == self.graphLayer {
            self.selectionLayer.removeFromSuperlayer()
            self.dateLabel.isHidden = true
            self.stepLabel.isHidden = true
        } else {
            self.selectionLayer.removeFromSuperlayer()

            self.selectionLayer.frame = CGRect(x: tappedLocation.x, y: self.selectionSpace, width: 1, height: point.y - self.selectionSpace)
            self.selectionLayer.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
            self.graphLayer.addSublayer(self.selectionLayer)

            self.dateLabel.text = "\(self.statisticsCollection[tappedGraphIndex].date)"
            self.stepLabel.text = "\(self.statisticsCollection[tappedGraphIndex].step) 걸음"

            self.dateLabel.sizeToFit()
            self.stepLabel.sizeToFit()
            self.dateLabel.center = CGPoint(x: tappedLocation.x, y: dateLabel.center.y)
            self.stepLabel.center = CGPoint(x: tappedLocation.x, y: stepLabel.center.y)

            self.dateLabel.frame.origin.x = max(self.dateLabel.frame.origin.x, 0)
            self.dateLabel.frame.origin.x = min(self.dateLabel.frame.origin.x, self.graphView.frame.width - self.dateLabel.frame.width)
            self.stepLabel.frame.origin.x = max(self.stepLabel.frame.origin.x, 0)
            self.stepLabel.frame.origin.x = min(self.stepLabel.frame.origin.x, self.graphView.frame.width - self.stepLabel.frame.width)

            self.dateLabel.isHidden = false
            self.stepLabel.isHidden = false
        }

    }

    // MARK: - functions

    override func layoutSubviews() {
        self.graphView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - self.bottomSpace)
        self.addSubview(self.graphView)

        dateLabel.center.y = selectionSpace * 0.25
        stepLabel.center.y = selectionSpace * 0.75
        self.graphView.addSubview(self.dateLabel)
        self.graphView.addSubview(self.stepLabel)

        self.graphLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.graphView.frame.height)
        self.textLayer.frame = CGRect(x: 0, y: self.frame.size.height - self.bottomSpace, width: self.frame.size.width, height: self.bottomSpace)
        self.layer.addSublayer(graphLayer)
        self.layer.addSublayer(textLayer)

        self.CGPoints = self.configureCGPoints(using: statisticsCollection)
        self.cleanLayer()
        self.drawBarChart()
    }

    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(drawStatistics(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(drawStatistics(_:)))
        self.graphView.addGestureRecognizer(tapGesture)
        self.graphView.addGestureRecognizer(panGesture)
    }

    private func configureCGPoints(using statisticsCollection: StatisticsCollection) -> [CGPoint] {

        guard let maxStatistics = statisticsCollection.maxStatistics() else { return [CGPoint]() }

        let maxStep = maxStatistics.step

        var CGPoints: [CGPoint] = []

        for (index, statistics) in statisticsCollection.statistics().enumerated() {
            let stepRatio = Float(statistics.step) / Float(maxStep)
            let reversedStepRatio = 1 - stepRatio
            let yCoordinate = (self.graphView.frame.height - self.topSpace) * CGFloat(reversedStepRatio) + self.topSpace
            let xCoordinate = self.xOffset * CGFloat(index) + self.xOffset / 2

            let point = CGPoint(x: xCoordinate, y: yCoordinate)
            CGPoints.append(point)
        }

        return CGPoints
    }

    private func cleanLayer() {
        self.graphLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.textLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }

    private func drawBarChart() {
        guard let CGPoints = self.CGPoints, CGPoints.count > 0 else { return }
        for point in CGPoints {
            let rectangleLayer = CAShapeLayer()
            rectangleLayer.frame = CGRect(x: point.x - self.barHalfWidth, y: point.y, width: self.barWidth, height: self.graphView.frame.height - point.y)
            rectangleLayer.cornerRadius = self.barWidth / 2

            rectangleLayer.zPosition = 1
            rectangleLayer.backgroundColor = .init(red: 255/255, green: 92/255, blue: 0, alpha: 1)
            self.graphLayer.addSublayer(rectangleLayer)

        }
    }

}
