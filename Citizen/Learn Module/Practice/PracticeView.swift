//
//  PracticeView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct PracticeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: PracticeViewModel
    
    init(questions: [Question], title: String, isMistakeReview: Bool = false) {
        _vm = StateObject(
            wrappedValue: PracticeViewModel(
                questions: questions,
                title: title,
                isMistakeReview: isMistakeReview
            )
        )
    }
    
    var body: some View {
        practiceView
            .navigationDestination(isPresented: $vm.showHint) {
                NavigationLazyView(HintView(question: vm.currentQuestion))
            }
            .sheet(isPresented: $vm.showSaveSheet) {
                SaveQuestionSheet(
                    question: vm.currentQuestion,
                    onChange: { vm.refreshSavedState() }
                )
            }
            .onAppear { vm.refreshSavedState() }
            .onDisappear { vm.stopVoice() }
            .voiceUnavailableNotice()
    }
}

// MARK: - Builder
extension PracticeView {
    private var practiceView: some View {
        CustomScrollView(title: vm.screenTitle, subTitle: vm.subtitle) {
            NavigationToolButton(
                vm.isCurrentQuestionSaved ? .system.bookmark : .system.bookmarkOutline,
                action: { vm.bookmarkButtonPressed() }
            )
            if vm.showsHintButton {
                NavigationToolButton(
                    .system.hint,
                    action: { vm.hintButtonPressed() }
                )
            }
        } content: { _ in
            progressRow
            question
                .padding(.bottom, isFaceIDPhone ? 70 : 86)
        }
        .overlay { BottomBarBackground() }
        .overlay { resultView }
        .safeAreaInset(edge: .bottom) { continueButton }
        .overlay { preview }
    }
    
    private var preview: some View {
        Group {
            if vm.showPreview {
                PracticePreviewView(vm: vm, dismiss: { dismiss() })
                    .transition(.offset(y: screenHeight))
            }
        }
        .animation(.smooth, value: vm.showPreview)
    }
    
    private var progressRow: some View {
        QuestionProgressHeader(
            counterText: vm.questionCounterText,
            questions: vm.sessionQuestions,
            currentQuestionID: vm.currentQuestion.id
        )
    }
    
    private var question: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                questionCard
                if vm.currentQuestion.additionalText != nil {
                    sentenceView
                }
                
                VStack {
                    ForEach(vm.displayedAnswers) { answer in
                        AnswerOptionRow(
                            answer: answer,
                            state: vm.rowState(for: answer),
                            showsLabel: vm.showsAnswerLabels,
                            revealed: vm.showSubView
                        )
                        .onTapGesture { vm.optionChanged(answer) }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .transition(
                .asymmetric(
                    insertion: .offset(x: screenWidth),
                    removal: .offset(x: -screenWidth)
                )
            )
            .id(vm.questionStep)
        }
        .animation(.smooth, value: vm.questionStep)
    }
    
    private var questionCard: some View {
        QuestionTextCard(
            text: vm.currentQuestion.question,
            isVoicing: vm.playingVoicePart == .question
        )
        .onTapGesture { vm.questionTapped() }
        .allowsHitTesting(vm.isVoiceActingEnabled)
    }
    
    private var sentenceView: some View {
        AccentSentenceView(segments: vm.additionalTextSegments)
            .font(.title3)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .voiceHighlight(isActive: vm.playingVoicePart == .sentence)
            .onTapGesture { vm.sentenceTapped() }
            .allowsHitTesting(vm.isVoiceActingEnabled)
    }
    
    private var continueButton: some View {
        QuizCTAButton(
            title: vm.ctaTitle,
            isEnabled: vm.ctaEnabled,
            action: vm.buttonPressed
        )
    }
    
    private var resultView: some View {
        Group {
            if vm.showSubView, let correct = vm.chosenAnswer?.isCorrect {
                AnswerResultBanner(
                    isCorrect: correct,
                    title: vm.bannerTitle,
                    message: vm.feedbackText
                )
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
                .id(vm.questionStep)
            }
        }
        .animation(.smooth, value: vm.showSubView)
    }
}
