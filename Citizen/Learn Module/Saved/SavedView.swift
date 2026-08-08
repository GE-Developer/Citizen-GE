//
//  SavedView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SavedView: View {
    @EnvironmentObject private var store: StoreManager
    
    @StateObject private var vm = SavedViewModel()
    
    @State private var fadingIDs: Set<String> = []
    
    var body: some View {
        savedFolders
            .navigationDestination(item: $vm.chosenFolder) { folder in
                NavigationLazyView(FolderQuestionsView(folder: folder))
            }
            .navigationDestination(isPresented: $vm.showPractice) {
                NavigationLazyView(
                    PracticeView(
                        questions: vm.practiceQuestions,
                        title: vm.title
                    )
                )
            }
            .onAppear { vm.refresh() }
            .alert(vm.renameActionTitle, isPresented: $vm.showRenameAlert) {
                TextField(vm.renamePlaceholder, text: $vm.renameFolderName)
                Button(vm.renameCancelTitle, role: .cancel) {}
                Button(vm.renameConfirmTitle, action: vm.confirmRename)
                    .disabled(!vm.canRename)
            }
    }
}

// MARK: - Builder
extension SavedView {
    private var savedFolders: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 14) {
                practiceCard
                countHeader
                if vm.isEmpty {
                    EmptyStateView(
                        icon: Image.system.folder,
                        title: vm.emptyFoldersText,
                        message: vm.emptyMessage
                    )
                    .padding(.top, 40)
                } else {
                    foldersGrid
                }
            }
            .animation(nil, value: vm.isEmpty)
        }
    }
    
    private var practiceCard: some View {
        AccentActionCard(
            icon: Image.system.practice,
            title: vm.practiceTitle,
            subtitle: vm.practiceSubtitle,
            action: { vm.practicePressed(isPremium: store.isPremium) }
        )
        .disabled(!vm.canPractice(isPremium: store.isPremium))
        .opacity(vm.canPractice(isPremium: store.isPremium) ? 1 : 0.6)
    }
    
    private var countHeader: some View {
        CountHeaderView(count: vm.foldersCountText, suffix: vm.foldersCountSuffix)
    }
    
    private var foldersGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())],
            spacing: 12
        ) {
            ForEach(vm.folders) { folder in
                folderCard(folder)
            }
        }
    }
    
    private func folderCard(_ folder: QuestionFolder) -> some View {
        Button(action: { vm.folderPressed(folder) }) {
            VStack(alignment: .leading, spacing: 12) {
                Image.system.folder
                    .font(.title3)
                    .foregroundStyle(Gradient.accent)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                        .lineLimit(1)
                    
                    Text(vm.questionCountText(folder))
                        .font(.caption)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .disabled(!vm.hasQuestions(folder))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15))
        .contextMenu {
            renameButton(folder)
            removeButton(folder)
        }
        .opacity(cardOpacity(folder))
        .transition(.identity)
    }
    
    private func renameButton(_ folder: QuestionFolder) -> some View {
        Button(action: { vm.renamePressed(folder) }) {
            Text(vm.renameActionTitle)
        }
    }
    
    private func removeButton(_ folder: QuestionFolder) -> some View {
        Button(role: .destructive) {
            deleteFolder(folder)
        } label: {
            Text(vm.removeActionTitle)
        }
    }
}

// MARK: - Logic
extension SavedView {
    private func cardOpacity(_ folder: QuestionFolder) -> Double {
        if fadingIDs.contains(folder.id) {
            return 0
        }
        
        return vm.hasQuestions(folder) ? 1 : 0.6
    }
    
    private func deleteFolder(_ folder: QuestionFolder) {
        let id = folder.id
        let fadeDuration = 0.2
        
        withAnimation(.easeInOut(duration: fadeDuration)) {
            _ = fadingIDs.insert(id)
        }
        
        Task {
            try? await Task.sleep(for: .seconds(fadeDuration))
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.remove(folder)
            }
            
            fadingIDs.remove(id)
        }
    }
}
