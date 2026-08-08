//
//  AnswerStorage.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class AnswerStorage {
    private var context: NSManagedObjectContext {
        stack.context
    }
    
    static let shared = AnswerStorage()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    // MARK: - Question Entity
    func saveAnswer(questionID: String, isCorrect: Bool) {
        let request: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", questionID)
        request.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(request).first {
                existing.isCorrect = isCorrect
            } else {
                let answer = QuestionEntity(context: context)
                answer.id = questionID
                answer.isCorrect = isCorrect
            }
            stack.saveContext()
        } catch {
        }
    }
    
    func fetchAllAnswered() -> [String: Bool] {
        let request = QuestionEntity.fetchRequest()
        do {
            return try context.fetch(request).reduce(into: [:]) { dict, entity in
                guard let id = entity.id else { return }
                dict[id] = entity.isCorrect
            }
        } catch {
            return [:]
        }
    }
    
    func removeAnswers(ids: [String]) {
        guard !ids.isEmpty else { return }
        stack.batchDelete(
            entityName: "QuestionEntity",
            predicate: NSPredicate(format: "id IN %@", ids)
        )
    }
    
    // MARK: - Global Mistake Entity
    func addToGlobalPool(questionID: String) {
        let request: NSFetchRequest<GlobalMistakeEntity> = GlobalMistakeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %@", questionID)
        request.fetchLimit = 1
        
        do {
            guard try context.fetch(request).isEmpty else { return }
            let entity = GlobalMistakeEntity(context: context)
            entity.questionID = questionID
            stack.saveContext()
        } catch {
        }
    }
    
    func fetchGlobalWrongIDs() -> [String] {
        let request = GlobalMistakeEntity.fetchRequest()
        do {
            return try context.fetch(request).compactMap { $0.questionID }
        } catch {
            return []
        }
    }
    
    func removeFromGlobalPool(questionID: String) {
        stack.batchDelete(
            entityName: "GlobalMistakeEntity",
            predicate: NSPredicate(format: "questionID == %@", questionID)
        )
    }
    
    // MARK: - Sync
    func snapshotAnswers() -> [ProgressSnapshot.AnsweredQuestion] {
        fetchAllAnswered()
            .map { ProgressSnapshot.AnsweredQuestion(id: $0.key, isCorrect: $0.value) }
            .sorted { $0.id < $1.id }
    }
    
    func removeAll() {
        stack.batchDelete(entityName: "QuestionEntity")
        stack.batchDelete(entityName: "GlobalMistakeEntity")
    }
    
    func restore(
        answers: [ProgressSnapshot.AnsweredQuestion],
        mistakeIDs: [String]
    ) {
        for answer in answers {
            let entity = QuestionEntity(context: context)
            entity.id = answer.id
            entity.isCorrect = answer.isCorrect
        }
        for id in Set(mistakeIDs) {
            let entity = GlobalMistakeEntity(context: context)
            entity.questionID = id
        }
    }
}
