//
//  ExamSessionView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var vm: ExamSessionViewModel
    
    init(session: ExamSession) {
        _vm = State(initialValue: ExamSessionViewModel(session: session))
    }
    
    var body: some View {
        sessionView
            .onAppear { vm.start() }
            .onDisappear { vm.stop() }
            .sheet(isPresented: $vm.showSaveSheet) {
                SaveQuestionSheet(
                    question: vm.currentItem.question,
                    onChange: { vm.refreshSavedState() }
                )
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { vm.checkDeadline() }
            }
            .alert(vm.finishAlertTitle, isPresented: $vm.showFinishAlert) {
                Button(vm.finishAlertConfirmTitle, role: .destructive) {
                    vm.confirmFinishSection()
                }
                Button(vm.cancelTitle, role: .cancel) {}
            } message: {
                Text(vm.finishAlertMessage)
            }
    }
}

// MARK: - Builder
extension ExamSessionView {
    private var sessionView: some View {
        CustomScrollView(title: "") {
            NavigationToolButton(
                vm.isCurrentQuestionSaved ? .system.bookmark : .system.bookmarkOutline,
                action: { vm.bookmarkButtonPressed() }
            )
        } centerItems: {
            navBarCenter
        } content: { _ in
            VStack(spacing: 20) {
                ExamProgressBar(
                    counterText: vm.counterText,
                    answeredFlags: vm.currentSection.items.map(\.isAnswered),
                    currentIndex: vm.itemIndex
                )
                
                question
                    .padding(.bottom, isFaceIDPhone ? 70 : 86)
            }
        }
        .overlay { BottomBarBackground() }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .overlay { interstitial }
        .overlay { results }
    }
    
    private var question: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                QuestionTextCard(
                    text: vm.currentItem.question.question,
                    isVoicing: false
                )
                
                if let imageUrl = vm.currentItem.question.imageUrl {
                    MediaImageView(
                        kind: .questionImage,
                        name: imageUrl,
                        sizing: .natural(height: 200)
                    )
                }
                
                if vm.currentItem.question.additionalText != nil {
                    sentenceView
                }
                
                VStack {
                    ForEach(vm.currentItem.shuffledAnswers) { answer in
                        AnswerOptionRow(
                            answer: answer,
                            state: vm.rowState(for: answer),
                            showsLabel: false,
                            revealed: false
                        )
                        .onTapGesture { vm.select(answer) }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .transition(questionTransition)
            .id(vm.questionStep)
        }
        .animation(.smooth, value: vm.questionStep)
    }
    
    private var sentenceView: some View {
        AccentSentenceView(
            segments: (vm.currentItem.question.additionalText ?? "").asRichSegments
        )
        .font(.title3)
        .fontWeight(.medium)
        .fontDesign(.rounded)
    }
    
    private var navBarCenter: some View {
        VStack(spacing: 2) {
            Text(timerInterval: vm.sectionStart...vm.sectionDeadline, countsDown: true)
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(Color.citizen.blackAndWhite)
                .opacity(vm.isSectionRunning ? 1 : 0)
            
            Text(vm.sectionLabel)
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundStyle(Color.citizen.mainText)
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(.horizontal, 70)
    }
    
    private var bottomBar: some View {
        ExamSessionBottomBar(
            ctaTitle: vm.ctaTitle,
            canGoBack: vm.canGoBack,
            canGoForward: vm.canGoForward,
            onBack: { vm.goBack() },
            onForward: { vm.goForward() },
            onCTA: { vm.ctaPressed() }
        )
    }
    
    private var interstitial: some View {
        Group {
            if vm.showInterstitial {
                VStack(spacing: 10) {
                    if let label = vm.announcedSectionLabel {
                        Text(label.uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .tracking(1)
                            .foregroundStyle(Color.citizen.secondaryText)
                    }
                    
                    Text(vm.announcedSectionName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                        .multilineTextAlignment(.center)
                }
                .fontDesign(.rounded)
                .padding(30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.citizen.background
                        .ignoresSafeArea()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.showInterstitial)
    }
    
    private var results: some View {
        Group {
            if vm.showResults {
                ExamResultsView(vm: vm, dismiss: { dismiss() })
                    .transition(.offset(y: screenHeight))
            }
        }
        .animation(.smooth, value: vm.showResults)
    }
}

// MARK: - Logic
extension ExamSessionView {
    private var questionTransition: AnyTransition {
        vm.direction == .forward
        ? .asymmetric(
            insertion: .offset(x: screenWidth),
            removal: .offset(x: -screenWidth)
        )
        : .asymmetric(
            insertion: .offset(x: -screenWidth),
            removal: .offset(x: screenWidth)
        )
    }
}
