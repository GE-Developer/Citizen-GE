//
//  ExamHistoryViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ExamHistoryViewModel {
    var showDeleteAlert = false
    var selectedMistakes: ExamMistakesRoute?

    var isEmpty: Bool {
        days.isEmpty
    }

    private(set) var days: [ExamHistoryDay] = []

    let title = L10n("Exam.History.title")
    let emptyTitle = L10n("Exam.History.Empty.title")
    let emptyMessage = L10n("Exam.History.Empty.message")
    let noMistakesTitle = L10n("Exam.History.noMistakes")
    let deleteAlertTitle = L10n("Exam.History.Delete.title")
    let deleteAlertMessage = L10n("Exam.History.Delete.message")
    let deleteAlertConfirmTitle = L10n("Exam.History.Delete.confirm")
    let cancelTitle = L10n("Exam.Session.Alert.cancel")

    private let history = ExamHistoryStorage.shared
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    private let timeFormatter = ExamHistoryViewModel.formatter(template: "j:mm")
    private let dayFormatter = ExamHistoryViewModel.formatter(template: "d MMMM")
    private let fullDayFormatter = ExamHistoryViewModel.formatter(template: "d MMMM yyyy")

    init() {
        refresh()
    }

    func refresh() {
        let groups = ExamAttempt.groups(from: history.allAttempts())
        let categories = categoryInfo()

        days = makeDays(from: groups.map { makeEntry($0, categories: categories) })
    }

    func select(_ entry: ExamHistoryEntry) {
        guard entry.hasMistakeDetails else { return }

        haptics.impact()
        selectedMistakes = ExamMistakesRoute(
            id: entry.id,
            title: entry.title,
            questionIDs: entry.wrongQuestionIDs
        )
    }

    func deleteButtonPressed() {
        haptics.impact()
        showDeleteAlert = true
    }

    func confirmDelete() {
        history.removeAll()
        refresh()
    }

    private func makeEntry(
        _ group: ExamAttemptGroup,
        categories: [String: ExamHistoryCategoryInfo]
    ) -> ExamHistoryEntry {
        let title = group.isFull
        ? L10n("Exam.FullExam.title")
        : group.categoryID.flatMap { categories[$0]?.name } ?? L10n("Exam.History.section")

        return ExamHistoryEntry(
            id: group.id.uuidString,
            date: group.date,
            title: title,
            timeText: timeFormatter.string(from: group.date),
            score: "\(group.correct)/\(group.total)",
            isPassed: group.isPassed,
            mistakeCount: group.mistakeCount,
            mistakesTitle: L10n("Exam.History.mistakes \(group.mistakeCount)"),
            verdict: group.isPassed
            ? L10n("Exam.History.passed")
            : L10n("Exam.History.failed"),
            sections: makeSectionRows(from: group.sections, categories: categories),
            wrongQuestionIDs: resolvedQuestionIDs(group.wrongQuestionIDs)
        )
    }

    // Rows of one attempt share a timestamp, so the fetch order is undefined —
    // they are put back into catalog order here.
    private func makeSectionRows(
        from attempts: [ExamAttempt],
        categories: [String: ExamHistoryCategoryInfo]
    ) -> [ExamHistorySectionRow] {
        attempts
            .map { attempt -> (row: ExamHistorySectionRow, index: Int) in
                let info = attempt.categoryID.flatMap { categories[$0] }

                let row = ExamHistorySectionRow(
                    id: attempt.id,
                    title: info?.name ?? L10n("Exam.History.section"),
                    score: "\(attempt.correct)/\(attempt.total)",
                    isPassed: attempt.isPassed
                )

                return (row, info?.index ?? .max)
            }
            .sorted { $0.index < $1.index }
            .map(\.row)
    }

    // Questions dropped from the catalog since the attempt can no longer be shown.
    private func resolvedQuestionIDs(_ ids: [String]) -> [String] {
        ids.filter { repository.question(byID: $0) != nil }
    }

    private func makeDays(from entries: [ExamHistoryEntry]) -> [ExamHistoryDay] {
        let calendar = Calendar.current
        var order: [Date] = []
        var grouped: [Date: [ExamHistoryEntry]] = [:]

        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)
            if grouped[day] == nil {
                order.append(day)
            }
            grouped[day, default: []].append(entry)
        }

        return order.map { day in
            ExamHistoryDay(
                id: day.timeIntervalSince1970,
                title: dayTitle(for: day, calendar: calendar),
                entries: grouped[day] ?? []
            )
        }
    }

    private func dayTitle(for day: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(day) {
            return L10n("Exam.History.today")
        }

        if calendar.isDateInYesterday(day) {
            return L10n("Exam.History.yesterday")
        }

        let isSameYear = calendar.isDate(day, equalTo: Date(), toGranularity: .year)
        return isSameYear
        ? dayFormatter.string(from: day)
        : fullDayFormatter.string(from: day)
    }

    private func categoryInfo() -> [String: ExamHistoryCategoryInfo] {
        repository.catalog.categories.reduce(into: [:]) { result, category in
            result[category.id] = ExamHistoryCategoryInfo(
                name: category.name,
                index: category.index
            )
        }
    }

    private static func formatter(template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LanguageManager.shared.currentLanguageID)
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }
}

// MARK: - ExamHistoryDay
struct ExamHistoryDay: Identifiable {
    let id: TimeInterval
    let title: String
    let entries: [ExamHistoryEntry]
}

// MARK: - ExamHistoryEntry
struct ExamHistoryEntry: Identifiable {
    var hasMistakeDetails: Bool {
        !wrongQuestionIDs.isEmpty
    }

    let id: String
    let date: Date
    let title: String
    let timeText: String
    let score: String
    let isPassed: Bool
    let mistakeCount: Int
    let mistakesTitle: String
    let verdict: String
    let sections: [ExamHistorySectionRow]
    let wrongQuestionIDs: [String]
}

// MARK: - ExamHistorySectionRow
struct ExamHistorySectionRow: Identifiable {
    let id: String
    let title: String
    let score: String
    let isPassed: Bool
}

// MARK: - ExamHistoryCategoryInfo
struct ExamHistoryCategoryInfo {
    let name: String
    let index: Int
}

// MARK: - ExamMistakesRoute
struct ExamMistakesRoute: Identifiable, Hashable {
    let id: String
    let title: String
    let questionIDs: [String]
}
