//
//  DetailFeedMapView.swift
//  Booster
//
//  Created by hiju on 2021/11/24.
//
import UIKit
import MapKit

final class DetailFeedMapView: BoosterMapView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    func configure(trackingModel value: TrackingModel) {
        let centerLocation = value.coordinates.center()
        setRegion(to: CLLocation(latitude: centerLocation.latitude ?? 0, longitude: centerLocation.longitude ?? 0), meterRadius: value.distance * 1000 + 50)

        configureMilestones(value.milestones)
    }

    func createMilestoneView(milestone: Milestone, color: UIColor) -> MKAnnotationView? {
        guard let newAnnotationView = UINib(nibName: PhotoAnnotationView.identifier, bundle: nil).instantiate(withOwner: self, options: nil).first as? PhotoAnnotationView
        else { return nil }

        newAnnotationView.canShowCallout = false
        newAnnotationView.photoImageView.image = UIImage(data: milestone.imageData)
        newAnnotationView.changeColor(color)

        newAnnotationView.centerOffset = CGPoint(x: 0, y: -newAnnotationView.frame.height / 2.0)
        return newAnnotationView
    }

    func createDotView() -> MKAnnotationView {
        let dotSize = CGSize(width: 18, height: 18)
        let newAnnotationView = MKAnnotationView.init(frame: CGRect(origin: .zero, size: dotSize))
        newAnnotationView.isUserInteractionEnabled = false
        newAnnotationView.layer.cornerRadius = newAnnotationView.frame.height / 2
        return newAnnotationView
    }
    
    private func configure() {
        layer.cornerRadius = frame.height / 17
    }

    private func configureMilestones(_ milestones: [Milestone]) {
        for milestone in milestones {
            if let latitude = milestone.coordinate.latitude,
               let longitude = milestone.coordinate.longitude {
                addAnnotation(type: .milestone,
                                      latitude,
                                      longitude)
            }
        }
    }
}
