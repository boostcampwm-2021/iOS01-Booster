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
              type name: String) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self,
                  let entity = NSEntityDescription.entity(forEntityName: name, in: self.container.viewContext)
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
                    single(.success(()))
                } catch let error {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func update(entityName: String, attributes: [String: Any], predicate: NSPredicate? = nil) -> Single<Void> {
        return Single.create { [weak self] single in
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

                    single(.success(()))
                } catch let error {
                    self.container.viewContext.rollback()
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func fetch<DataType: NSManagedObject>() -> Single<[DataType]> {
        return Single.create { [weak self] single in
            guard let self = self
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.perform {
                do {
                    let context = try self.container.viewContext.fetch(DataType.fetchRequest())
                    guard let context = context as? [DataType]
                    else { return }

                    single(.success(context))
                } catch let error {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func fetch<DataType: NSManagedObject>(entityName: String,
                                          predicate: NSPredicate) -> Single<[DataType]> {
        return Single.create { [weak self] single in
            guard let self = self
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.perform {
                let request = NSFetchRequest<DataType>.init(entityName: entityName)
                request.predicate = predicate
                do {
                    let result = try self.container.viewContext.fetch(request)
                    single(.success(result))
                } catch let error {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func delete(entityName: String, predicate: NSPredicate? = nil) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self
            else { return Disposables.create() }

            let backgroundContext = self.container.newBackgroundContext()

            backgroundContext.perform {
                let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
                request.predicate = predicate
                
                do {
                    let delete = NSBatchDeleteRequest(fetchRequest: request)
                    try self.container.viewContext.execute(delete)
                    single(.success(()))
                } catch let error {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
