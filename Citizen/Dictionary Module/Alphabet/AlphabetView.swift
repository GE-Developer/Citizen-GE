//
//  AlphabetView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AlphabetView: View {
    @State private var vm = AlphabetViewModel()
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    }
    
    var body: some View {
        content
            .onDisappear { vm.stopVoice() }
            .voiceUnavailableNotice()
    }
}

// MARK: - Builder
extension AlphabetView {
    private var content: some View {
        CustomScrollView(
            title: vm.title,
            navBarItems: { EmptyView() },
            content: { _ in scrollContent }
        )
    }
    
    private var scrollContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                FormHeaderView(vm.letterNumberText)
                
                if let selected = vm.selectedLetter {
                    featuredCard(selected)
                }
            }
            
            transcriptionToggleRow
            allLettersSection
        }
    }
    
    private var transcriptionToggleRow: some View {
        CustomForm {
            CustomToggleRow(
                isOn: $vm.showTranscription,
                icon: .system.transcription,
                title: vm.transcriptionToggleTitle
            )
        }
    }
    
    private var allLettersSection: some View {
        VStack(spacing: 12) {
            FormHeaderView(vm.allLettersTitle)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(vm.letters) { letterCell($0) }
            }
        }
    }
    
    private func featuredCard(_ letter: AlphabetLetter) -> some View {
        HStack(spacing: 14) {
            exampleImage(letter)
                .frame(maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 17))
                .padding(.leading, 3)
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 6) {
                if !letter.exampleWord.isEmpty {
                    Text(letter.exampleWord)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.mainText)
                    if vm.showTranscription, !letter.exampleWordTransliteration.isEmpty {
                        Text(vm.exampleTransliteration(for: letter))
                            .font(.subheadline)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color.citizen.secondaryText)
                    }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            
            Spacer()
            
            if vm.showPlayButton {
                Button(action: { vm.playWord(letter) }) {
                    ZStack {
                        Circle()
                            .fill(Gradient.accent)
                        if vm.isPlaying {
                            SonarRing()
                        }
                        Image.system.play
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.citizen.white)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 20)
                    .padding(.trailing, 20)
                }
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.citizen.groupBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Gradient.accent.opacity(0.12))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 1)
        }
    }
    
    private func exampleImage(_ letter: AlphabetLetter) -> some View {
        MediaImageView(
            kind: .alphabetImage,
            name: letter.exampleImage,
            sizing: .container(contentMode: .fill)
        )
    }
    
    @ViewBuilder
    private func letterCell(_ letter: AlphabetLetter) -> some View {
        let isSelected = vm.isSelected(letter)
        
        Button {
            vm.select(letter)
            vm.playLetter(letter)
        } label: {
            VStack(spacing: 4) {
                Text(letter.character)
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.citizen.mainText)
                if vm.showTranscription {
                    Text(vm.transliteration(for: letter))
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit) // клетки всегда квадратные
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.citizen.groupBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Gradient.accent.opacity(isSelected ? 0.18 : 0))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Gradient.accent.opacity(isSelected ? 0.7 : 0), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
    }
}

// MARK: - SonarRing
private struct SonarRing: View {
    @State private var expand = false
    
    var body: some View {
        Circle()
            .stroke(Color.citizen.accent, lineWidth: 3)
            .scaleEffect(expand ? 1.5 : 1)
            .opacity(expand ? 0 : 0.8)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1)
                    .repeatForever(autoreverses: false)
                ) {
                    expand = true
                }
            }
    }
}
