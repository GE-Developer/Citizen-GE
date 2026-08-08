//
//  SearchView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var vm = SearchViewModel()
    @State private var showPayWall = false
    
    var body: some View {
        content
            .task { vm.load() }
            .navigationDestination(item: $vm.selectedQuestion) { question in
                NavigationLazyView(HintView(question: question))
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
    }
}

// MARK: - Builder
extension SearchView {
    private var content: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            scrollContent
        }
    }
    
    private var scrollContent: some View {
        LazyVStack(spacing: 16) {
            CustomNavigationTextField(
                text: $vm.searchText,
                autoFocused: true,
                placeholder: vm.searchPlaceholder,
                deleteAction: vm.clearSearchText
            )
            CountHeaderView(
                count: vm.questionsCountText,
                suffix: vm.questionsCountSuffix
            )
            if vm.showPlaceholder {
                placeholder
            } else {
                CustomCapsulePicker(
                    selection: $vm.selectedFilter,
                    items: vm.availableFilters,
                    capsuleName: { $0.title }
                )
                resultsSection
            }
        }
    }
    
    private var placeholder: some View {
        EmptyStateView(
            icon: Image.system.magnifyingglass,
            title: vm.emptyTitle,
            message: vm.emptyMessage
        )
        .padding(.top, 40)
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        if vm.showNoResults {
            noResults
        } else {
            ForEach(vm.visibleRows) { row in
                OccurrenceCard(row: row, action: { vm.select(row) })
                    .premiumOption($showPayWall, isIncluded: row.isPremium)
                    .overlay(premiumOverlay(row))
            }
        }
    }
    
    private var noResults: some View {
        Text(vm.noResultsText)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 40)
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
