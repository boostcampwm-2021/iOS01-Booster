import Foundation
import CoreData
import RxSwift

final class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()

    private init() {
        container = NSPersistentContainer(name: "Booster")
        container.loadPersistentStores { _, _ in }
    }

    private var container: NSPersistentContainer

    func save(attributes: [String: Any],
              type name: String,
              completion handler: @escaping (Result<Void, Error>) -> Void) {
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: container.viewContext)
        else { return }

        let backgroundContext = container.newBackgroundContext()

        backgroundContext.perform { [weak self] in
            guard let self = self
            else { return }

            let entityObject = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
            attributes.forEach { entityObject.setValue($0.value, forKey: $0.key) }

            let context = self.container.viewContext

            do {
                try context.save()
                handler(.success(()))
            } catch let error {
                handler(.failure(error))
            }
        }
    }

    func save(attributes: [String: Any],
              type name: String) -> Observable<Void> {
        return Observable.create { observer in

            guard let entity = NSEntityDescription.entity(forEntityName: name, in: self.container.viewContext)
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.performAndWait { [weak self] in
                guard let self = self
                else { return }

                let entityObject = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
                attributes.forEach { entityObject.setValue($0.value, forKey: $0.key) }

                let context = self.container.viewContext

                do {
                    try context.save()
                    observer.onNext(())
                } catch let error {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func save<DataType: NSManagedObject>(value: [String: Any],
              type name: String,
              predicate: NSPredicate,
              completion handler: @escaping (Result<DataType, Error>) -> Void) {
        let backgroundContext = container.newBackgroundContext()

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

    func update(entityName: String, attributes: [String: Any], predicate: NSPredicate? = nil) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.perform {
                let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
                request.predicate = predicate
                do {
                    let context = self.container.viewContext
                    let result = try context.fetch(request)
                    guard let updateModel = result.first as? NSManagedObject
                    else { return }

                    for element in attributes {
                        updateModel.setValue(element.value, forKey: element.key)
                    }

                    try context.save()

                    observer.onCompleted()
                } catch let error {
                    self.container.viewContext.rollback()
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func fetch<DataType: NSManagedObject>() -> Observable<[DataType]> {
        return Observable.create { [weak self] observer in
            guard let self = self
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.perform {
                do {
                    let context = try self.container.viewContext.fetch(DataType.fetchRequest())
                    guard let context = context as? [DataType]
                    else { return }

                    observer.onNext(context)
                } catch let error {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func fetch<DataType: NSManagedObject>(completion handler: @escaping (Result<[DataType], Error>) -> Void) {
        let backgroundContext = container.newBackgroundContext()

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
        let backgroundContext = container.newBackgroundContext()

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

    func fetch<DataType: NSManagedObject>(entityName: String,
                                          predicate: NSPredicate) -> Observable<[DataType]> {
        return Observable.create { [weak self] observer in
            guard let self = self
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.perform {
                let request = NSFetchRequest<DataType>.init(entityName: entityName)
                request.predicate = predicate
                do {
                    let result = try self.container.viewContext.fetch(request)
                    observer.onNext(result)
                } catch let error {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func delete<DataType: NSManagedObject>(entityName: String,
                                           predicate: NSPredicate,
                                           completion handler: @escaping (Result<DataType, Error>) -> Void) {
        let backgroundContext = container.newBackgroundContext()

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
        let backgroundContext = container.newBackgroundContext()

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

    func delete(entityName: String, predicate: NSPredicate) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.perform {
                let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
                request.predicate = predicate
                do {
                    let objects = try self.container.viewContext.fetch(request)
                    guard let model = objects.first as? NSManagedObject
                    else { return }
                    self.container.viewContext.delete(model)
                    try self.container.viewContext.save()
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
