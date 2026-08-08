//
//  ScoreStorage.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class ScoreStorage {
    private var context: NSManagedObjectContext {
        stack.context
    }
    
    static let shared = ScoreStorage()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    // MARK: - Public API
    func fetchTotal() -> Int {
        Int(Self.fetchEntity(in: context)?.total ?? 0)
    }
    
    func setTotal(_ value: Int) {
        Self.upsert(in: context).total = Int64(value)
        stack.saveContext()
    }
    
    func reset() {
        stack.batchDelete(entityName: "ScoreEntity")
    }
    
    // MARK: - Helpers
    private static func fetchEntity(in context: NSManagedObjectContext) -> ScoreEntity? {
        let request: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
    
    private static func upsert(in context: NSManagedObjectContext) -> ScoreEntity {
        if let existing = fetchEntity(in: context) { return existing }
        
        return ScoreEntity(context: context)
    }
}
