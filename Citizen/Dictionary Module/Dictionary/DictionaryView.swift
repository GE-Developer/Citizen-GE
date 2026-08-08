//
//  DictionaryView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct DictionaryView: View {
    @State private var vm = DictionaryViewModel()
    @State private var fadingKeys: Set<String> = []
    
    var body: some View {
        content
            .task(id: LanguageManager.shared.currentLanguageID) { await vm.load() }
            .navigationDestination(item: $vm.selectedOccurrenceWord) { word in
                NavigationLazyView(WordOccurrencesView(word: word))
            }
            .navigationDestination(isPresented: $vm.showAlphabet) {
                NavigationLazyView(AlphabetView())
            }
    }
}

// MARK: - Builder
extension DictionaryView {
    private var content: some View {
        CustomScrollView(
            title: vm.title,
            withBackButton: false,
            tabBarIsVisible: true,
            navBarItems: { EmptyView() },
            content: { _ in scrollContent }
        )
    }
    
    @ViewBuilder
    private var scrollContent: some View {
        if vm.isLoading {
            DictionarySkeletonView()
        } else {
            VStack(spacing: 14) {
                alphabetCard
                CountHeaderView(
                    count: vm.wordsCountText,
                    suffix: vm.wordsSavedSuffix
                )
                if vm.isEmpty {
                    emptyState
                } else {
                    populatedContent
                }
            }
            .animation(nil, value: vm.isEmpty)
        }
    }
    
    private var populatedContent: some View {
        LazyVStack(alignment: .leading, spacing: 14) {
            CustomCapsulePicker(
                selection: $vm.selectedFilter,
                items: vm.availableFilters,
                capsuleName: { $0.title }
            )
            CustomNavigationTextField(
                text: $vm.searchText,
                placeholder: vm.searchPlaceholder,
                deleteAction: vm.clearSearchText
            )
            CustomCapsulePicker(
                selection: $vm.selectedSort,
                capsuleName: { $0.title }
            )
            wordsSection
        }
    }
    
    private var alphabetCard: some View {
        Button(action: vm.openAlphabet) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Gradient.accent)
                    Text(vm.alphabetIconLetter)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.citizen.white)
                }
                .frame(maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.vertical, 5)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(vm.alphabetTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                    Text(vm.alphabetSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                Spacer()
                
                if vm.voiceActingOn {
                    Image.system.sound
                        .font(.body)
                        .foregroundStyle(Gradient.accent)
                }
                Image.system.chevron
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .padding()
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.citizen.groupBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Gradient.accent.opacity(0.12))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 1)
            }
        }
    }
    
    @ViewBuilder
    private var wordsSection: some View {
        if vm.displayedWords.isEmpty {
            noResults
        } else {
            LazyVStack(spacing: 0) {
                ForEach(vm.displayedWords) { wordCard($0) }
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
    
    private func wordCard(_ word: SavedWord) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            cardHeader(word)
            wordSection(word.entry)
            savedAsSection(word)
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.citizen.groupBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15))
        .contextMenu { removeButton(word) }
        .opacity(fadingKeys.contains(word.id) ? 0 : 1)
        .padding(.bottom, 16)
        .transition(.identity)
    }
    
    @ViewBuilder
    private func cardHeader(_ word: SavedWord) -> some View {
        let occurrenceCount = vm.occurrenceCount(for: word)
        
        HStack {
            Badge(word.entry.partOfSpeech)
            Spacer()
            
            if occurrenceCount > 0 {
                Button(action: { vm.showOccurrences(word) }) {
                    HStack {
                        Badge("#\(occurrenceCount)")
                        Image.system.chevron
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.citizen.secondaryText)
                    }
                }
            }
        }
    }
    
    private func wordSection(_ word: WordEntry) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(word.word)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
            Text(vm.transliteration(word.transliteration))
                .font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.citizen.secondaryText)
            if let translation = word.translation {
                Text(translation)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    @ViewBuilder
    private func savedAsSection(_ word: SavedWord) -> some View {
        if !word.savedAsKeys.isEmpty {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Gradient.accent)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.savedAsLabel.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .tracking(0.5)
                        .foregroundStyle(Gradient.accent)
                        .lineLimit(1)
                    ForEach(word.savedAsKeys, id: \.self) { key in
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.citizen.mainText)
                            .lineLimit(1)
                    }
                }
                .minimumScaleFactor(0.5)
            }
            .padding(.top, 3)
        }
    }
    
    private func removeButton(_ word: SavedWord) -> some View {
        Button(role: .destructive) {
            deleteWord(word)
        } label: {
            Text(vm.removeActionTitle)
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: Image.system.dictionaryOutline,
            title: vm.emptyTitle,
            message: vm.emptyMessage
        )
        .padding(.top, 40)
    }
}

// MARK: - Logic
extension DictionaryView {
    private func deleteWord(_ word: SavedWord) {
        let key = word.id
        let fadeDuration = 0.2
        
        withAnimation(.easeInOut(duration: fadeDuration)) {
            _ = fadingKeys.insert(key)
        }
        Task {
            try? await Task.sleep(for: .seconds(fadeDuration))
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.remove(word)
            }
            fadingKeys.remove(key)
        }
    }
}
