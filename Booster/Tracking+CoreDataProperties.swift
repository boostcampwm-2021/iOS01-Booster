//
//  Tracking+CoreDataProperties.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/11.
//
//

import Foundation
import CoreData

extension Tracking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tracking> {
        return NSFetchRequest<Tracking>(entityName: "Tracking")
    }

    @NSManaged public var calories: Int64
    @NSManaged public var content: String?
    @NSManaged public var coordinates: Data?
    @NSManaged public var distance: Double
    @NSManaged public var endDate: Date?
    @NSManaged public var imageData: Data?
    @NSManaged public var milestones: Data?
    @NSManaged public var seconds: Int64
    @NSManaged public var startDate: Date?
    @NSManaged public var steps: Int64
    @NSManaged public var title: String?
    @NSManaged public var address: String?

}

extension Tracking: Identifiable {

}
