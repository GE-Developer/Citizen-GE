//
//  SavedQuestionsStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class SavedQuestionsStore {
    private var context: NSManagedObjectContext {
        stack.context
    }
    
    static let shared = SavedQuestionsStore()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    func folders(validQuestionIDs: Set<String>) -> [QuestionFolder] {
        let request = QuestionFolderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try context
                .fetch(request)
                .compactMap { entity in
                    guard let id = entity.id,
                          let name = entity.name else { return nil }
                    
                    return QuestionFolder(
                        id: id,
                        name: name,
                        count: questionIDs(inFolder: id).intersection(validQuestionIDs).count
                    )
                }
        } catch {
            return []
        }
    }
    
    @discardableResult
    func createFolder(named name: String) -> QuestionFolder {
        let entity = QuestionFolderEntity(context: context)
        let id = UUID().uuidString
        entity.id = id
        entity.name = name
        entity.createdAt = Date()
        stack.saveContext()
        
        return QuestionFolder(id: id, name: name, count: 0)
    }
    
    func folderIDs(for questionID: String) -> Set<String> {
        let request = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %@", questionID)
        
        let items = (try? context.fetch(request)) ?? []
        
        return Set(items.compactMap { $0.folderID })
    }
    
    func questionIDs(inFolder folderID: String) -> Set<String> {
        let request = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "folderID == %@", folderID)
        
        let items = (try? context.fetch(request)) ?? []
        
        return Set(items.compactMap { $0.questionID })
    }
    
    func allSavedQuestionIDs() -> Set<String> {
        let request = SavedQuestionEntity.fetchRequest()
        let items = (try? context.fetch(request)) ?? []
        
        return Set(items.compactMap { $0.questionID })
    }
    
    func contains(_ questionID: String) -> Bool {
        let request = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %@", questionID)
        request.fetchLimit = 1
        
        return ((try? context.count(for: request)) ?? 0) > 0
    }
    
    func foldersCount() -> Int {
        let request = QuestionFolderEntity.fetchRequest()
        
        return (try? context.count(for: request)) ?? 0
    }
    
    func removeOrphans(validQuestionIDs: Set<String>) {
        guard !validQuestionIDs.isEmpty else { return }
        
        stack.batchDelete(
            entityName: "SavedQuestionEntity",
            predicate: NSPredicate(format: "NOT (questionID IN %@)", validQuestionIDs)
        )
    }
    
    
    @discardableResult
    func toggle(questionID: String, folderID: String) -> Bool {
        if isSaved(questionID: questionID, inFolder: folderID) {
            remove(questionID: questionID, folderID: folderID)
            return false
        }
        
        let entity = SavedQuestionEntity(context: context)
        entity.questionID = questionID
        entity.folderID = folderID
        entity.createdAt = Date()
        
        stack.saveContext()
        
        return true
    }
    
    func remove(questionID: String, folderID: String) {
        let predicateFormat = "questionID == %@ AND folderID == %@"
        
        stack.batchDelete(
            entityName: "SavedQuestionEntity",
            predicate: NSPredicate(format: predicateFormat, questionID, folderID)
        )
    }
    
    func renameFolder(_ folderID: String, to name: String) {
        let request = QuestionFolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", folderID)
        request.fetchLimit = 1
        
        guard let entity = try? context.fetch(request).first else { return }
        
        entity.name = name
        stack.saveContext()
    }
    
    func removeFolder(_ folderID: String) {
        stack.batchDelete(
            entityName: "SavedQuestionEntity",
            predicate: NSPredicate(format: "folderID == %@", folderID)
        )
        stack.batchDelete(
            entityName: "QuestionFolderEntity",
            predicate: NSPredicate(format: "id == %@", folderID)
        )
    }
    
    func removeAll() {
        stack.batchDelete(entityName: "SavedQuestionEntity")
        stack.batchDelete(entityName: "QuestionFolderEntity")
    }
    
    // MARK: - Sync
    func snapshotFolders() -> [ProgressSnapshot.FolderItem] {
        let request = QuestionFolderEntity.fetchRequest()
        
        do {
            return try context
                .fetch(request)
                .compactMap { entity in
                    guard let id = entity.id,
                          let name = entity.name else { return nil }
                    
                    return ProgressSnapshot.FolderItem(
                        id: id,
                        name: name,
                        createdAt: (entity.createdAt ?? Date()).timeIntervalSince1970
                    )
                }
        } catch {
            return []
        }
    }
    
    func snapshotSavedQuestions() -> [ProgressSnapshot.SavedQuestionItem] {
        let request = SavedQuestionEntity.fetchRequest()
        
        do {
            return try context
                .fetch(request)
                .compactMap { entity in
                    guard let questionID = entity.questionID,
                          let folderID = entity.folderID else {
                        return nil
                    }
                    
                    return ProgressSnapshot.SavedQuestionItem(
                        questionID: questionID,
                        folderID: folderID,
                        createdAt: (entity.createdAt ?? Date()).timeIntervalSince1970
                    )
                }
        } catch {
            return []
        }
    }
    
    func restore(
        folders: [ProgressSnapshot.FolderItem],
        savedQuestions: [ProgressSnapshot.SavedQuestionItem]
    ) {
        for folder in folders {
            let entity = QuestionFolderEntity(context: context)
            entity.id = folder.id
            entity.name = folder.name
            entity.createdAt = Date(timeIntervalSince1970: folder.createdAt)
        }
        
        for item in savedQuestions {
            let entity = SavedQuestionEntity(context: context)
            entity.questionID = item.questionID
            entity.folderID = item.folderID
            entity.createdAt = Date(timeIntervalSince1970: item.createdAt)
        }
    }
    
    private func isSaved(questionID: String, inFolder folderID: String) -> Bool {
        let predicateFormat = "questionID == %@ AND folderID == %@"
        let request = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: predicateFormat, questionID, folderID)
        request.fetchLimit = 1
        
        return ((try? context.count(for: request)) ?? 0) > 0
    }
    
}
