//
//  MistakesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct MistakesView: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var vm = MistakesViewModel()
    @State private var showPayWall = false
    
    var body: some View {
        mistakes
            .navigationDestination(item: $vm.selectedQuestion) { question in
                NavigationLazyView(HintView(question: question))
            }
            .navigationDestination(isPresented: $vm.showPractice) {
                NavigationLazyView(
                    PracticeView(
                        questions: vm.practiceQuestions,
                        title: vm.practiceHeaderTitle,
                        isMistakeReview: true
                    )
                )
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
            .onAppear { vm.refresh() }
    }
}

// MARK: - Builder
extension MistakesView {
    private var mistakes: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            LazyVStack(spacing: 16) {
                practiceCard
                
                CountHeaderView(count: vm.questionsCountText, suffix: vm.questionsCountSuffix)
                
                if vm.isEmpty {
                    emptyState
                } else {
                    questionsList
                }
            }
            .animation(nil, value: vm.isEmpty)
        }
    }
    
    private var practiceCard: some View {
        AccentActionCard(
            icon: Image.system.practice,
            title: vm.practiceTitle,
            subtitle: vm.practiceSubtitle(isPremium: store.isPremium),
            detail: vm.practiceFilterDetail,
            action: { vm.practicePressed(isPremium: store.isPremium) }
        )
        .disabled(!vm.canPractice(isPremium: store.isPremium))
        .opacity(vm.canPractice(isPremium: store.isPremium) ? 1 : 0.6)
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: Image.system.warning,
            title: vm.emptyTitle,
            message: vm.emptyMessage
        )
        .padding(.top, 40)
    }
    
    @ViewBuilder
    private var questionsList: some View {
        CustomCapsulePicker(
            selection: $vm.selectedFilter,
            items: vm.availableFilters,
            capsuleName: { $0.title }
        )
        
        ForEach(vm.visibleRows) { row in
            OccurrenceCard(row: row, action: { vm.select(row) })
                .premiumOption($showPayWall, isIncluded: row.isPremium)
                .overlay(premiumOverlay(row))
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }
}
