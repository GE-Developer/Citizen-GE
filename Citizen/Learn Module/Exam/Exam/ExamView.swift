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
            .navigationDestination(item: $vm.activeSession) { session in
                NavigationLazyView(ExamSessionView(session: session))
            }
            .navigationDestination(isPresented: $vm.showRules) {
                NavigationLazyView(ExamRulesView())
            }
            .navigationDestination(isPresented: $vm.showHistory) {
                NavigationLazyView(ExamHistoryView())
            }
    }
}

// MARK: - Builder
extension ExamView {
    private var exam: some View {
        CustomScrollView(title: vm.title) {
            NavigationToolButton(.system.history, action: { vm.historyButtonPressed() })
            NavigationToolButton(.system.info, action: { vm.rulesButtonPressed() })
        } content: { _ in
            LazyVStack(spacing: 25) {
                heroCard
                sectionsBlock
            }
        }
    }

    private var heroCard: some View {
        ExamHeroCard(
            icon: Image.system.timer,
            title: vm.fullExamTitle,
            subtitle: vm.fullExamSubtitle,
            stats: [
                ExamHeroStat(value: vm.questionsValue, caption: vm.questionsCaption),
                ExamHeroStat(value: vm.limitValue, caption: vm.limitCaption),
                ExamHeroStat(value: vm.thresholdValue, caption: vm.thresholdCaption, isAccent: true)
            ],
            buttonTitle: vm.startButtonTitle,
            action: { vm.startFullExam() }
        )
    }

    private var sectionsBlock: some View {
        VStack(spacing: 12) {
            sectionsHeader

            ForEach(vm.sectionRows) { row in
                ExamSectionRow(
                    icon: .system.graduationCap,
                    title: row.title,
                    action: { vm.startSectionExam(id: row.id) }
                )
            }
        }
    }

    private var sectionsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(vm.sectionsTitle)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.citizen.mainText)

            Spacer()

            Text(vm.sectionsCaption)
                .font(.footnote)
                .foregroundStyle(Color.citizen.secondaryText)
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .padding(.top, 5)
    }
}
