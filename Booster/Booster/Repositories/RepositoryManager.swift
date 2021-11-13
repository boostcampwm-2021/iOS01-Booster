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
            value.forEach { entityObject.setValue($0.value, forKey: $0.key) }

            let context = self.container.viewContext

            do {
                try context.save()
                handler(.success(()))
            } catch let error {
                handler(.failure(error))
            }
        }
    }

    func save<DataType: NSManagedObject>(value: [String: Any],
              type name: String,
              predicate: NSPredicate,
              completion handler: @escaping (Result<DataType, Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self
            else { return }

            let request = NSFetchRequest<DataType>.init(entityName: name)
            request.predicate = predicate

            do {
                let objects = try self.container.viewContext.fetch(request)
                value.forEach { objects[0].setValue($0.value, forKey: $0.key) }
                try self.container.viewContext.save()
                handler(.success(objects[0]))
            } catch let error {
                handler(.failure(error))
            }
        }
    }

    func fetch<DataType: NSManagedObject>(completion handler: @escaping (Result<[DataType], Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self
            else { return }

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

    func fetch<DataType: NSManagedObject>(entityName: String,
                                          predicate: NSPredicate,
                                          completion handler: @escaping (Result<[DataType], Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self
            else { return }

            let request = NSFetchRequest<DataType>.init(entityName: entityName)
            request.predicate = predicate
            do {
                let result = try self.container.viewContext.fetch(request)
                handler(.success(result))
            } catch let error {
                handler(.failure(error))
            }
        }
    }

    func delete<DataType: NSManagedObject>(entityName: String,
                                           predicate: NSPredicate,
                                           completion handler: @escaping (Result<DataType, Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self
            else { return }

            let request = NSFetchRequest<DataType>.init(entityName: entityName)
            request.predicate = predicate

            do {
                let objects = try self.container.viewContext.fetch(request)
                self.container.viewContext.delete(objects[0])
                try self.container.viewContext.save()
                handler(.success(objects[0]))
            } catch let error {
                handler(.failure(error))
            }
        }
    }

    func delete(entityName: String, completion handler: @escaping (Result<Void, Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self
            else { return }

            let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)

            do {
                let delete = NSBatchDeleteRequest(fetchRequest: request)
                try self.container.viewContext.execute(delete)
                handler(.success(()))
            } catch let error {
                handler(.failure(error))
            }
        }
    }
}
