//
//  SaveQuestionViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class SaveQuestionViewModel: ObservableObject {
    @Published var newFolderName = ""
    
    @Published private(set) var folders: [QuestionFolder] = []
    @Published private(set) var savedFolderIDs: Set<String> = []
    
    var canCreateFolder: Bool {
        !newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    let title = L10n("Questions.SaveSheet.title")
    let subtitle = L10n("Questions.SaveSheet.subtitle")
    let foldersHeader = L10n("Questions.SaveSheet.foldersHeader")
    let emptyFoldersText = L10n("Questions.SaveSheet.emptyFolders")
    let newFolderTitle = L10n("Questions.SaveSheet.newFolder")
    
    private let question: Question
    private let onChange: () -> Void
    private let savedStore = SavedQuestionsStore.shared
    private let haptic = HapticsManager.shared
    
    init(question: Question, onChange: @escaping () -> Void) {
        self.question = question
        self.onChange = onChange
        refresh()
    }
    
    func isSaved(in folder: QuestionFolder) -> Bool {
        savedFolderIDs.contains(folder.id)
    }
    
    func folderCountText(_ folder: QuestionFolder) -> String {
        L10n("Questions.SaveSheet.folderCount \(folder.count)")
    }
    
    func toggleFolder(_ folder: QuestionFolder) {
        savedStore.toggle(questionID: question.id, folderID: folder.id)
        haptic.selectionChanged()
        refresh()
        onChange()
    }
    
    func createFolderAndSave() {
        let name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let folder = savedStore.createFolder(named: name)
        savedStore.toggle(questionID: question.id, folderID: folder.id)
        haptic.notification(type: .success)
        newFolderName = ""
        refresh()
        onChange()
    }
    
    private func refresh() {
        folders = savedStore.folders()
        savedFolderIDs = savedStore.folderIDs(for: question.id)
    }
}
