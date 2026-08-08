//
//  FolderQuestionsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct FolderQuestionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var store: StoreManager
    
    @StateObject private var vm: FolderQuestionsViewModel
    
    @State private var showPayWall = false
    @State private var fadingIDs: Set<String> = []
    
    init(folder: QuestionFolder) {
        _vm = StateObject(wrappedValue: FolderQuestionsViewModel(folder: folder))
    }
    
    var body: some View {
        folderQuestions
            .navigationDestination(item: $vm.selectedQuestion) { question in
                NavigationLazyView(HintView(question: question))
            }
            .navigationDestination(isPresented: $vm.showPractice) {
                NavigationLazyView(
                    PracticeView(
                        questions: vm.practiceQuestions,
                        title: vm.practiceHeaderTitle
                    )
                )
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
            .onAppear {
                vm.refresh()
                if vm.rows.isEmpty {
                    dismiss()
                }
            }
    }
}

// MARK: - Builder
extension FolderQuestionsView {
    private var folderQuestions: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            LazyVStack(spacing: 16) {
                AccentActionCard(
                    icon: Image.system.practice,
                    title: vm.practiceTitle,
                    subtitle: vm.practiceSubtitle,
                    detail: vm.practiceFilterDetail,
                    action: { vm.practicePressed(isPremium: store.isPremium) }
                )
                .disabled(!vm.canPractice(isPremium: store.isPremium))
                .opacity(vm.canPractice(isPremium: store.isPremium) ? 1 : 0.6)
                
                CountHeaderView(count: vm.questionsCountText, suffix: vm.questionsCountSuffix)
                
                CustomCapsulePicker(
                    selection: $vm.selectedFilter,
                    items: vm.availableFilters,
                    capsuleName: { $0.title }
                )
                
                ForEach(vm.visibleRows) { row in
                    OccurrenceCard(row: row, action: { vm.select(row) })
                        .premiumOption($showPayWall, isIncluded: row.isPremium)
                        .overlay(premiumOverlay(row))
                        .contentShape(
                            .contextMenuPreview,
                            RoundedRectangle(cornerRadius: 15)
                        )
                        .contextMenu { removeButton(row) }
                        .opacity(fadingIDs.contains(row.id) ? 0 : 1)
                        .transition(.identity)
                }
            }
        }
    }
    
    @ViewBuilder
    private func premiumOverlay(_ row: OccurrenceRow) -> some View {
        if row.isPremium {
            PremiumView(.star)
                .padding(4)
                .background {
                    Circle()
                        .fill(Color.citizen.background)
                        .shadow(color: Color.citizen.background, radius: 2)
                }
                .offset(x: 10, y: 10)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
        }
    }
    
    private func removeButton(_ row: OccurrenceRow) -> some View {
        Button(role: .destructive) {
            deleteQuestion(row)
        } label: {
            Text(vm.removeActionTitle)
        }
    }
}

// MARK: - Logic
extension FolderQuestionsView {
    private func deleteQuestion(_ row: OccurrenceRow) {
        let id = row.id
        let fadeDuration = 0.2
        
        withAnimation(.easeInOut(duration: fadeDuration)) {
            _ = fadingIDs.insert(id)
        }
        
        Task {
            try? await Task.sleep(for: .seconds(fadeDuration))
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.remove(row)
            }
            
            fadingIDs.remove(id)
            
            if vm.rows.isEmpty {
                dismiss()
            }
        }
    }
}
