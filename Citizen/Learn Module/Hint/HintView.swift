//
//  HintView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct HintView: View {
    @State private var vm: HintViewModel
    
    private let screenshotProtector = ScreenshotManager.shared
    
    init(question: Question) {
        _vm = State(initialValue: HintViewModel(question: question))
    }
    
    var body: some View {
        hintView
            .onDisappear { vm.stopVoice() }
            .voiceUnavailableNotice()
            .sheet(item: $vm.selectedWord) { _ in
                WordDetailSheet(vm: vm)
            }
            .sheet(isPresented: $vm.showSaveSheet) {
                SaveQuestionSheet(
                    question: vm.question,
                    onChange: { vm.refreshSavedState() }
                )
            }
            .screenshotDisabled(screenshotProtector.isScreenshotProtectionOn)
    }
}

// MARK: - Builder
extension HintView {
    private var hintView: some View {
        CustomScrollView(title: vm.title, subTitle: vm.subTitle) {
            NavigationToolButton(
                vm.isQuestionSaved ? .system.bookmark : .system.bookmarkOutline,
                action: { vm.bookmarkButtonPressed() }
            )
        } content: { _ in
            VStack(alignment: .leading, spacing: 20) {
                questionSection
                Divider()
                
                if vm.hasSentence {
                    sentenceSection
                    Divider()
                }
                
                answersSection
                
                if vm.hasExplanations {
                    Divider()
                    explanationsSection
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(vm.questionHeader)
            RichTextView(
                segments: vm.questionSegments,
                highlightsDictionaryWords: true,
                onTapWord: vm.selectWord
            )
            .font(.title3)
            .fontWeight(.regular)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
            
            if let translation = vm.questionTranslation {
                translationText(translation)
            }
            
            if vm.showsVoiceButtons {
                voiceButton { vm.playQuestion() }
            }
        }
    }
    
    private var sentenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(vm.sentenceHeader)
            HStack(spacing: 10) {
                Capsule()
                    .frame(width: 2)
                    .foregroundStyle(Gradient.accent)
                RichTextView(
                    segments: vm.sentenceSegments,
                    highlightsDictionaryWords: true,
                    onTapWord: vm.selectWord
                )
                .font(.title3)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let translationSegments = vm.sentenceTranslationSegments {
                RichTextView(segments: translationSegments)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if vm.showsVoiceButtons {
                voiceButton { vm.playSentence() }
            }
        }
    }
    
    private var explanationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(vm.explanationsHeader)
            ForEach(vm.explanations.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    Capsule()
                        .frame(width: 2)
                        .foregroundStyle(Gradient.accent)
                    Text(vm.explanations[index].asMarkdown)
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.mainText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var answersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(vm.answersHeader)
            VStack(spacing: 10) {
                showAnswerRow
                ForEach(vm.answerRows) { row in
                    answerRow(row)
                }
            }
        }
    }
    
    private var showAnswerRow: some View {
        CustomToggleRow(isOn: $vm.showCorrectAnswer, title: vm.showAnswerTitle)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
    }
    
    private func answerRow(_ row: HintAnswerRow) -> some View {
        HStack(spacing: 12) {
            Text(row.label)
                .font(.title3)
                .fontWeight(.regular)
                .fontDesign(.rounded)
                .foregroundStyle(Gradient.accent)
                .frame(width: 18, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                RichTextView(
                    segments: row.segments,
                    highlightsDictionaryWords: true,
                    onTapWord: vm.selectWord
                )
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                
                if let translation = row.translation {
                    Text(translation)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
                
                if vm.showsVoiceButtons {
                    voiceButton { vm.playAnswer(row) }
                        .padding(.top, 4)
                }
            }
            
            Spacer(minLength: 0)
            
            if row.isCorrect {
                Image.system.checkmarkAndXmark(true)
                    .fontWeight(.semibold)
                    .foregroundStyle(Gradient.green)
                    .opacity(vm.showCorrectAnswer ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.citizen.groupBackground)
        }
    }
    
    private func voiceButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image.system.sound
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Gradient.accent)
                .padding(10)
                .background {
                    Circle()
                        .fill(Gradient.accent.opacity(0.12))
                }
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .tracking(1)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func translationText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
