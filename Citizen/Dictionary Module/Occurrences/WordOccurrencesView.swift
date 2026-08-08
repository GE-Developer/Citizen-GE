//
//  WordOccurrencesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct WordOccurrencesView: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var vm: WordOccurrencesViewModel
    @State private var showPayWall = false
    
    init(word: SavedWord) {
        _vm = State(initialValue: WordOccurrencesViewModel(word: word))
    }
    
    var body: some View {
        content
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
    }
}

// MARK: - Builder
extension WordOccurrencesView {
    private var content: some View {
        CustomScrollView(title: vm.title, subTitle: vm.subtitle) {
            EmptyView()
        } content: { _ in
            scrollContent
        }
    }
    
    @ViewBuilder
    private var scrollContent: some View {
        if vm.rows.isEmpty {
            emptyState
        } else {
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
                
                VStack(alignment: .leading) {
                    Text(vm.headerTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Gradient.accent)
                        .fontDesign(.rounded)
                    Text(vm.headerTransliteration)
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .fontDesign(.monospaced)
                    if let translation = vm.headerTranslation {
                        Text(translation)
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.citizen.mainText)
                            .fontDesign(.rounded)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
    
    private var emptyState: some View {
        Text(vm.emptyText)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 40)
    }
}
