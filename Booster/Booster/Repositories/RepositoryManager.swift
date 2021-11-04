import Foundation
import CoreData

class RepositoryManager {
    enum ResultType<Success, Failure: Error> {
        case success(Success)
        case failure(Failure)
    }

    init() {
        entityName = ""
    }

    private var entityName: String
    private var entity: NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: container.viewContext)
    }
    private lazy var container: NSPersistentContainer = {
            let container = NSPersistentContainer(name: entityName)
            container.loadPersistentStores { (_, _) in }
            return container
    }()
    private lazy var backgroundContext: NSManagedObjectContext = {
        return container.newBackgroundContext()
    }()

    func save(value: [String: Any], type name: String, completion handler: @escaping (ResultType<Void, Error>) -> Void ) {
        self.entityName = name
        guard let entity = entity else { return }
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            let entityObject = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
            value.forEach {
                entityObject.setValue($0.value, forKey: $0.key)
            }
            let context = self.container.viewContext
            do {
                try context.save()
                handler(.success(()))
            } catch let error {
                handler(.failure(error))
            }
        }
    }

    func fetch<DataType: NSManagedObject>(type name: String, completion handler: @escaping (ResultType<[DataType], Error>) -> Void) {
        self.entityName = name
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                return
            }

            do {
                let context = try self.container.viewContext.fetch(DataType.fetchRequest())
                guard let context = context as? [DataType] else { return }
                handler(.success(context))
            } catch let error {
                handler(.failure(error))
            }
        }
    }
}
