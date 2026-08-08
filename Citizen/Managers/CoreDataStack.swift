//
//  CoreDataStack.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class CoreDataStack {
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    var isSyncSuppressed = false
    var onProgressMutation: (() -> Void)?
    
    static let shared = CoreDataStack()
    
    private let container: NSPersistentContainer
    private let answerContinerBase = "AnswerContainer"
    
    private init() {
        container = NSPersistentContainer(name: answerContinerBase)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            if !isSyncSuppressed {
                onProgressMutation?()
            }
        } catch {
        }
    }
    
    func batchDelete(entityName: String, predicate: NSPredicate? = nil) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        delete.resultType = .resultTypeObjectIDs
        
        do {
            let result = try context.execute(delete) as? NSBatchDeleteResult
            let ids = result?.result as? [NSManagedObjectID] ?? []
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: ids],
                into: [context]
            )
            
            if !ids.isEmpty, !isSyncSuppressed {
                onProgressMutation?()
            }
        } catch {
        }
    }
    
    func hasAnyRows(entityName: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.fetchLimit = 1
        
        let rows = (try? context.fetch(request)) ?? []
        
        return !rows.isEmpty
    }
}
