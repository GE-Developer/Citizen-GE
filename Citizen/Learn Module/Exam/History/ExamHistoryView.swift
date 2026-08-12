//
//  ExamHistoryView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamHistoryView: View {
    @State private var vm = ExamHistoryViewModel()
    
    var body: some View {
        history
            .navigationDestination(item: $vm.selectedMistakes) { route in
                NavigationLazyView(ExamMistakesView(route: route))
            }
            .onAppear { vm.refresh() }
            .alert(vm.deleteAlertTitle, isPresented: $vm.showDeleteAlert) {
                Button(vm.deleteAlertConfirmTitle, role: .destructive) {
                    vm.confirmDelete()
                }
                Button(vm.cancelTitle, role: .cancel) {}
            } message: {
                Text(vm.deleteAlertMessage)
            }
    }
}

// MARK: - Builder
extension ExamHistoryView {
    private var history: some View {
        CustomScrollView(title: vm.title) {
            if !vm.isEmpty {
                NavigationToolButton(.system.trash, action: { vm.deleteButtonPressed() })
            }
        } content: { _ in
            if vm.isEmpty {
                emptyState
            } else {
                timeline
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: .system.history,
            title: vm.emptyTitle,
            message: vm.emptyMessage
        )
        .padding(.top, 60)
    }
    
    private var timeline: some View {
        LazyVStack(spacing: 25) {
            ForEach(vm.days) { day in
                VStack(alignment: .leading, spacing: 12) {
                    dayHeader(day.title)
                    
                    ForEach(day.entries) { entry in
                        attemptCard(entry)
                    }
                }
            }
        }
    }
    
    private func dayHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .tracking(1)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func attemptCard(_ entry: ExamHistoryEntry) -> some View {
        Button(action: { vm.select(entry) }) {
            VStack(alignment: .leading, spacing: 14) {
                attemptHeader(entry)
                
                if !entry.sections.isEmpty {
                    Divider()
                    
                    VStack(spacing: 10) {
                        ForEach(entry.sections) { section in
                            sectionRow(section)
                        }
                    }
                }
                
                Divider()
                mistakesRow(entry)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .disabled(!entry.hasMistakeDetails)
    }
    
    private func attemptHeader(_ entry: ExamHistoryEntry) -> some View {
        HStack(spacing: 14) {
            Image.system.graduationCap
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Gradient.accent)
                .frame(width: 24, height: 24)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Gradient.accent.opacity(0.15))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.citizen.mainText)
                    .lineLimit(1)
                
                Text(entry.timeText)
                    .font(.caption)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            
            Spacer(minLength: 8)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.score)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(verdictColor(entry.isPassed))
                
                Text(entry.verdict)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .lineLimit(1)
        }
        .fontDesign(.rounded)
        .minimumScaleFactor(0.7)
    }
    
    private func sectionRow(_ section: ExamHistorySectionRow) -> some View {
        HStack(spacing: 10) {
            Text(section.title)
                .font(.subheadline)
                .foregroundStyle(Color.citizen.mainText)
                .lineLimit(1)
            
            Spacer(minLength: 8)
            
            Text(section.score)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(verdictColor(section.isPassed))
            
            statusIcon(section.isPassed)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(verdictColor(section.isPassed))
        }
        .fontDesign(.rounded)
        .minimumScaleFactor(0.7)
    }
    
    private func mistakesRow(_ entry: ExamHistoryEntry) -> some View {
        HStack(spacing: 6) {
            Text(entry.mistakeCount == 0 ? vm.noMistakesTitle : entry.mistakesTitle)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(mistakesColor(entry))
            
            Spacer(minLength: 0)
            
            if entry.hasMistakeDetails {
                Image.system.chevron
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

// MARK: - Logic
extension ExamHistoryView {
    private func verdictColor(_ isPassed: Bool) -> Color {
        isPassed ? Color.citizen.greenLight : Color.citizen.redLight
    }
    
    private func mistakesColor(_ entry: ExamHistoryEntry) -> Color {
        entry.mistakeCount == 0 ? Color.citizen.greenLight : Color.citizen.redLight
    }
    
    private func statusIcon(_ isPassed: Bool) -> Image {
        isPassed ? .system.checkmark : .system.xmark
    }
}
