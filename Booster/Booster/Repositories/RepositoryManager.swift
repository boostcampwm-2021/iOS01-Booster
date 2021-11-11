import Foundation
import CoreData

final class RepositoryManager {
    init() {
        container = NSPersistentContainer(name: "Booster")
        container.loadPersistentStores { _, _ in }
        entityName = ""
    }

    private var entityName: String
    private var container: NSPersistentContainer
    private lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext = container.newBackgroundContext()
        return backgroundContext
    }()

    func save(value: [String: Any],
              type name: String,
              completion handler: @escaping (Result<Void, Error>) -> Void ) {
        self.entityName = name
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: container.viewContext)
        else { return }

        backgroundContext.perform { [weak self] in
            guard let self = self
            else { return }

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

    func fetch<DataType: NSManagedObject>(completion handler: @escaping (Result<[DataType], Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self
            else {
                return
            }

            do {
                let context = try self.container.viewContext.fetch(DataType.fetchRequest())
                guard let context = context as? [DataType]
                else { return }

                handler(.success(context))
            } catch let error {
                handler(.failure(error))
            }
        }
    }
}
