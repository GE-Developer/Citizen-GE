//
//  ExamView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamView: View {
    @State private var vm = ExamViewModel()
    
    var body: some View {
        exam
    }
}

// MARK: - Builder
extension ExamView {
    private var exam: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            LazyVStack(spacing: 16) {
                fullExamCard
                subjectCards
            }
        }
    }
    
    private var fullExamCard: some View {
        AccentActionCard(
            icon: Image.system.timer,
            title: vm.fullExamTitle,
            subtitle: vm.fullExamSubtitle,
            action: { vm.startFullExam() }
        )
    }
    
    @ViewBuilder
    private var subjectCards: some View {
        ForEach(Array(vm.subjects.enumerated()), id: \.element.id) { index, option in
            HomeActionCard(
                icon: Image.system.timer,
                color: subjectColor(index),
                count: vm.subjectQuestionsCount,
                title: option.title,
                subtitle: option.subtitle,
                action: { vm.startSubjectExam(id: option.id) }
            )
        }
    }
}

// MARK: - Logic
extension ExamView {
    private func subjectColor(_ index: Int) -> Color {
        let palette = [
            Color.citizen.greenLight,
            Color.citizen.redLight,
            Color.citizen.yellowLight
        ]
        return palette[index % palette.count]
    }
}
