//
//  ExamHistoryStorage.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class ExamHistoryStorage {
    private var context: NSManagedObjectContext {
        stack.context
    }
    
    static let shared = ExamHistoryStorage()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    // MARK: - Public API
    func record(_ attempts: [ExamAttempt]) {
        guard !attempts.isEmpty else { return }
        
        for attempt in attempts {
            let entity = ExamAttemptEntity(context: context)
            entity.attemptID = attempt.attemptID
            entity.kind = attempt.kind.rawValue
            entity.categoryID = attempt.categoryID
            entity.date = attempt.date
            entity.correct = Int16(clamping: attempt.correct)
            entity.total = Int16(clamping: attempt.total)
            entity.isPassed = attempt.isPassed
            entity.wrongQuestionIDs = Self.pack(attempt.wrongQuestionIDs)
        }
        
        stack.saveContext()
    }
    
    func allAttempts() -> [ExamAttempt] {
        let request: NSFetchRequest<ExamAttemptEntity> = ExamAttemptEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context
                .fetch(request)
                .compactMap(Self.attempt)
        } catch {
            return []
        }
    }
    
    func removeAll() {
        stack.batchDelete(entityName: "ExamAttemptEntity")
    }
    
    // MARK: - Sync
    func snapshotItems() -> [ProgressSnapshot.ExamAttemptItem] {
        let request: NSFetchRequest<ExamAttemptEntity> = ExamAttemptEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request).compactMap { entity in
                guard let attemptID = entity.attemptID,
                      let kind = entity.kind,
                      let date = entity.date else { return nil }
                
                return ProgressSnapshot.ExamAttemptItem(
                    attemptID: attemptID.uuidString,
                    kind: kind,
                    categoryID: entity.categoryID,
                    date: date.timeIntervalSince1970,
                    correct: Int(entity.correct),
                    total: Int(entity.total),
                    isPassed: entity.isPassed,
                    wrongQuestionIDs: Self.unpack(entity.wrongQuestionIDs)
                )
            }
        } catch {
            return []
        }
    }
    
    func restore(_ items: [ProgressSnapshot.ExamAttemptItem]) {
        for item in items {
            let entity = ExamAttemptEntity(context: context)
            entity.attemptID = UUID(uuidString: item.attemptID) ?? UUID()
            entity.kind = item.kind
            entity.categoryID = item.categoryID
            entity.date = Date(timeIntervalSince1970: item.date)
            entity.correct = Int16(clamping: item.correct)
            entity.total = Int16(clamping: item.total)
            entity.isPassed = item.isPassed
            entity.wrongQuestionIDs = Self.pack(item.wrongQuestionIDs ?? [])
        }
    }
    
    // MARK: - Private helpers
    private nonisolated static func attempt(from entity: ExamAttemptEntity) -> ExamAttempt? {
        guard let attemptID = entity.attemptID,
              let rawKind = entity.kind,
              let kind = ExamAttemptKind(rawValue: rawKind),
              let date = entity.date else { return nil }
        
        return ExamAttempt(
            attemptID: attemptID,
            kind: kind,
            categoryID: entity.categoryID,
            date: date,
            correct: Int(entity.correct),
            total: Int(entity.total),
            isPassed: entity.isPassed,
            wrongQuestionIDs: unpack(entity.wrongQuestionIDs)
        )
    }
    
    private nonisolated static func pack(_ ids: [String]) -> String {
        ids.joined(separator: "\n")
    }
    
    private nonisolated static func unpack(_ raw: String?) -> [String] {
        guard let raw, !raw.isEmpty else { return [] }
        return raw.components(separatedBy: "\n")
    }
}
