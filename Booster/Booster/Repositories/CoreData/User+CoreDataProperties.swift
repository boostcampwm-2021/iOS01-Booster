import Foundation
import CoreData

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var age: Int64
    @NSManaged public var gender: String?
    @NSManaged public var height: Int64
    @NSManaged public var nickName: String?
    @NSManaged public var weight: Int64

}

extension User: Identifiable {

}
