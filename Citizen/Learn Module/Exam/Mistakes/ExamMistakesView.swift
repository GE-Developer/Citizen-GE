//
//  ExamMistakesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamMistakesView: View {
    @State private var vm: ExamMistakesViewModel

    init(route: ExamMistakesRoute) {
        _vm = State(initialValue: ExamMistakesViewModel(route: route))
    }

    var body: some View {
        mistakes
            .navigationDestination(item: $vm.selectedQuestion) { question in
                NavigationLazyView(HintView(question: question))
            }
            .onAppear { vm.refresh() }
    }
}

// MARK: - Builder
extension ExamMistakesView {
    private var mistakes: some View {
        CustomScrollView(title: vm.title, subTitle: vm.subtitle) {
            EmptyView()
        } content: { _ in
            LazyVStack(spacing: 16) {
                CountHeaderView(
                    count: vm.questionsCountText,
                    suffix: vm.questionsCountSuffix
                )

                if vm.isEmpty {
                    emptyState
                } else {
                    questionsList
                }
            }
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: .system.warning,
            title: vm.emptyTitle,
            message: vm.emptyMessage
        )
        .padding(.top, 40)
    }

    private var questionsList: some View {
        ForEach(vm.rows) { row in
            OccurrenceCard(row: row, action: { vm.select(row) })
        }
    }
}
