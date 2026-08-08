//
//  PracticePreviewView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct PracticePreviewView: View {
    @ObservedObject private var vm: PracticeViewModel
    
    private let dismiss: () -> Void
    
    private let reviewPlaceholderHeight: CGFloat = 216
    
    init(vm: PracticeViewModel, dismiss: @escaping () -> Void) {
        self.vm = vm
        self.dismiss = dismiss
    }
    
    var body: some View {
        practicePreview
            .alert(vm.restartAlertTitle, isPresented: $vm.showRestartAlert) {
                Button(vm.restartAlertCancelTitle, role: .cancel) {}
                Button(
                    vm.restartAlertConfirmTitle,
                    role: .destructive,
                    action: vm.restartSession
                )
            } message: {
                Text(vm.restartAlertMessage)
            }
    }
}

// MARK: - Builder
extension PracticePreviewView {
    private var practicePreview: some View {
        ZStack {
            Color.citizen.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topSection
                    .layoutPriority(1)
                bottomSection
            }
        }
    }
    
    private var topSection: some View {
        ZStack(alignment: .top) {
            Color.citizen.whiteAndBlack
                .clipShape(UnevenRoundedRectangle(
                    bottomLeadingRadius: 24,
                    bottomTrailingRadius: 24)
                )
                .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 28) {
                titleHeader
                ringBlock
                statsRow
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: screenHeight * 0.45)
    }
    
    private var titleHeader: some View {
        VStack(spacing: 8) {
            Badge(vm.statusBadgeText)
            
            Text(vm.headerTitle.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .multilineTextAlignment(.center)
                .tracking(1)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        }
    }
    
    private var ringBlock: some View {
        ProgressRing(
            progress: vm.previewProgress,
            subtitle: vm.ringCaption,
            withPercent: true,
            lineWidth: 12,
            isDark: true
        )
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var statsRow: some View {
        HStack(alignment: .center, spacing: 3) {
            statCell(
                value: vm.totalQuestionsText,
                label: vm.totalLabel
            )
            Divider()
                .padding(.vertical, 2)
            statCell(
                value: vm.mistakesCountText,
                label: vm.mistakesLabel
            )
            if vm.showsRoundsStat {
                Divider()
                    .padding(.vertical, 2)
                statCell(
                    value: vm.roundsCompletedText,
                    label: vm.roundsLabel
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var bottomSection: some View {
        VStack(spacing: 3) {
            if !vm.previewMistakes.isEmpty {
                mistakesPager
                Spacer(minLength: 0)
            } else if vm.isCompleted {
                completedBlock
                    .padding(.horizontal)
            } else {
                Color.clear
                    .frame(height: reviewPlaceholderHeight)
                Spacer(minLength: 0)
            }
            
            actionButtons
                .padding(.horizontal)
        }
        .padding(.bottom, isFaceIDPhone ? -12 : 12)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 10) {
            if vm.isCompleted {
                primaryButton(title: vm.primaryActionTitle, action: dismiss)
                if vm.showsRestartButton {
                    secondaryButton(
                        title: vm.restartTitle,
                        action: vm.restartButtonPressed
                    )
                }
            } else {
                primaryButton(title: vm.primaryActionTitle, action: vm.continuePractice)
                if vm.showsRestartButton {
                    secondaryButton(
                        title: vm.restartTitle,
                        action: vm.restartButtonPressed
                    )
                }
                ghostButton(title: vm.exitTitle, action: dismiss)
            }
        }
    }
    
    private var mistakesPager: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(vm.toReviewHeaderText.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Gradient.accent)
                .padding(.horizontal)
            
            TabView {
                ForEach(vm.previewMistakes) { question in
                    mistakeCard(question)
                        .padding(.horizontal)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 170)
        }
        .padding(.top, 13)
        .padding(.bottom, 7)
    }
    
    private var completedBlock: some View {
        VStack(spacing: 10) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.citizen.greenLight.opacity(0.15))
                Image.system.checkmark
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.citizen.greenLight)
            }
            .frame(width: 64, height: 64)
            
            Text(vm.completedTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.mainText)
                .lineLimit(1)
            
            Text(vm.completedMessageText)
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundStyle(Color.citizen.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineLimit(5)
            
            Spacer()
        }
        .minimumScaleFactor(0.5)
        .fontDesign(.rounded)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(Color.citizen.mainText)
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .fontDesign(.rounded)
        .frame(maxWidth: .infinity)
    }
    
    private func mistakeCard(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            mistakeRowHeader(question)
            questionText(question)
            
            let segments = vm.sentenceSegments(for: question)
            if !segments.isEmpty {
                AccentSentenceView(segments: segments, lineLimit: 2)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.citizen.groupBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func mistakeRowHeader(_ question: Question) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.citizen.redLight.opacity(0.15))
                Image.system.xmark
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.citizen.redLight)
            }
            .frame(width: 28, height: 28)
            
            Text(vm.mistakeRowTitle(for: question))
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
            
            Spacer()
        }
    }
    
    private func questionText(_ question: Question) -> some View {
        Text(question.question)
            .font(.subheadline)
            .fontWeight(.regular)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .multilineTextAlignment(.leading)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func primaryButton(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Gradient.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func secondaryButton(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.citizen.groupBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func ghostButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
    }
}
