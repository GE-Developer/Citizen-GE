//
//  ExamSessionViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ExamSessionViewModel {
    var showFinishAlert = false
    var showSaveSheet = false

    var currentSection: ExamSection {
        session.sections[sectionIndex]
    }

    var currentItem: ExamSectionItem {
        currentSection.items[itemIndex]
    }

    var sectionLabel: String {
        label(forSectionAt: sectionIndex)
    }

    var showInterstitial: Bool {
        announcedSectionIndex != nil
    }

    // The announcement runs ahead of the content swap, so it must not read
    // the current section — that one is still the previous one on screen.
    var announcedSectionName: String {
        session.sections[announcedSectionIndex ?? sectionIndex].categoryName
    }

    var announcedSectionLabel: String? {
        guard case .full = session.mode else { return nil }
        return label(forSectionAt: announcedSectionIndex ?? sectionIndex)
    }

    var isLastQuestion: Bool {
        itemIndex == currentSection.totalCount - 1
    }

    var ctaTitle: String {
        isLastQuestion ? finishSectionTitle : nextTitle
    }

    var counterText: String {
        L10n("Questions.counter \(itemIndex + 1) \(currentSection.totalCount)")
    }

    var canGoBack: Bool {
        itemIndex > 0
    }

    var canGoForward: Bool {
        itemIndex < currentSection.totalCount - 1
    }

    var unansweredCount: Int {
        currentSection.totalCount - currentSection.answeredCount
    }

    var finishAlertMessage: String {
        L10n("Exam.Session.FinishAlert.message \(unansweredCount)")
    }

    var isPassed: Bool {
        session.isPassed
    }

    var verdictTitle: String {
        switch session.mode {
        case .full:
            return session.isPassed
            ? L10n("Exam.Results.passedTitle")
            : L10n("Exam.Results.failedTitle")
        case .single:
            return session.isPassed
            ? L10n("Exam.Results.sectionPassedTitle")
            : L10n("Exam.Results.sectionFailedTitle")
        }
    }

    var scoreText: String {
        "\(session.correctTotal)/\(session.questionTotal)"
    }

    var pointsText: String {
        let signed = pointsDelta > 0 ? "+\(pointsDelta)" : "\(pointsDelta)"
        return L10n("Exam.Results.points \(signed)")
    }

    var resultRows: [ExamResultRow] {
        session.sections.map { section in
            ExamResultRow(
                id: section.categoryID,
                title: section.categoryName,
                score: "\(section.correctCount)/\(section.totalCount)",
                isPassed: section.isPassed
            )
        }
    }

    private(set) var session: ExamSession
    private(set) var sectionIndex = 0
    private(set) var itemIndex = 0
    private(set) var questionStep = 0
    private(set) var direction: ExamNavigationDirection = .forward
    private(set) var sectionStart = Date()
    private(set) var sectionDeadline = Date()
    private(set) var isSectionRunning = false
    private(set) var announcedSectionIndex: Int?
    private(set) var showResults = false
    private(set) var pointsDelta = 0
    private(set) var isCurrentQuestionSaved = false

    private var deadlineTask: Task<Void, Never>?
    private var interstitialTask: Task<Void, Never>?
    private var isFinalized = false
    private var didStart = false
    private var lastMoveAt = Date.distantPast

    let nextTitle = L10n("Exam.Session.next")
    let finishSectionTitle = L10n("Exam.Session.finishSection")
    let finishAlertTitle = L10n("Exam.Session.FinishAlert.title")
    let finishAlertConfirmTitle = L10n("Exam.Session.FinishAlert.confirm")
    let cancelTitle = L10n("Exam.Session.Alert.cancel")
    let resultsCaption = L10n("Exam.Results.caption")
    let doneTitle = L10n("Exam.Results.done")
    let retryTitle = L10n("Exam.Results.retry")

    private let repository = QuizRepository.shared
    private let history = ExamHistoryStorage.shared
    private let score = ScoreManager.shared
    private let haptic = HapticsManager.shared
    private let sound = SoundManager.shared
    private let savedStore = SavedQuestionsStore.shared
    private let minMoveInterval: TimeInterval = 0.35
    private let announcementCoverDelay: TimeInterval = 0.3
    private let announcementHold: TimeInterval = 1.2

    init(session: ExamSession) {
        self.session = session
    }

    func start() {
        if !didStart {
            didStart = true
            handleQuestionChange()
            announceSection(at: 0, swappingContent: false)
            return
        }

        // stop() cancels the deadline watcher on disappear; if the view ever
        // re-appears over a still-running section, the watcher must come back.
        guard isSectionRunning else { return }
        checkDeadline()

        if isSectionRunning {
            armDeadlineTask()
        }
    }

    func stop() {
        deadlineTask?.cancel()
        interstitialTask?.cancel()
    }

    func select(_ answer: Answer) {
        guard isSectionRunning,
              currentItem.chosenAnswerID != answer.id else { return }

        haptic.selectionChanged()
        session.sections[sectionIndex].items[itemIndex].chosenAnswerID = answer.id
    }

    func rowState(for answer: Answer) -> AnswerRowState {
        currentItem.chosenAnswerID == answer.id ? .selected : .idle
    }

    func goForward() {
        guard canGoForward else { return }
        move(by: 1, direction: .forward)
    }

    func goBack() {
        guard canGoBack else { return }
        move(by: -1, direction: .backward)
    }

    func ctaPressed() {
        if isLastQuestion {
            finishSectionTapped()
        } else {
            goForward()
        }
    }

    func bookmarkButtonPressed() {
        haptic.impact()
        showSaveSheet = true
    }

    func refreshSavedState() {
        isCurrentQuestionSaved = savedStore.contains(currentItem.question.id)
    }

    func finishSectionTapped() {
        haptic.impact()

        if unansweredCount > 0 {
            showFinishAlert = true
        } else {
            finishSection()
        }
    }

    func confirmFinishSection() {
        finishSection()
    }

    func checkDeadline() {
        guard isSectionRunning, Date() >= sectionDeadline else { return }
        finishSection()
    }

    func restart() {
        guard let newSession = ExamSession(mode: session.mode, catalog: repository.catalog) else { return }

        haptic.impact()
        session = newSession
        sectionIndex = 0
        itemIndex = 0
        questionStep += 1
        direction = .forward
        showResults = false
        isFinalized = false
        pointsDelta = 0

        handleQuestionChange()
        announceSection(at: 0, swappingContent: false)
    }

    private func startSection() {
        isSectionRunning = true
        sectionStart = Date()
        sectionDeadline = sectionStart.addingTimeInterval(ExamConfig.sectionDuration)
        armDeadlineTask()
    }

    private func armDeadlineTask() {
        deadlineTask?.cancel()
        let deadline = sectionDeadline
        deadlineTask = Task { [weak self] in
            let interval = deadline.timeIntervalSinceNow
            if interval > 0 {
                try? await Task.sleep(for: .seconds(interval))
            }

            guard !Task.isCancelled, let self else { return }
            self.finishSection()
        }
    }

    private func finishSection() {
        guard isSectionRunning else { return }
        isSectionRunning = false
        deadlineTask?.cancel()
        // The deadline can fire while the confirmation alert is on screen;
        // a stale confirmation must not finish the NEXT section.
        showFinishAlert = false

        session.sections[sectionIndex].isFinished = true
        recordSectionMistakes(currentSection)

        if sectionIndex < session.sections.count - 1 {
            advanceToNextSection()
        } else {
            finalize()
        }
    }

    private func advanceToNextSection() {
        announceSection(at: sectionIndex + 1, swappingContent: true)
    }

    // The announcement covers the screen BEFORE the questions behind it are
    // swapped — otherwise the next section's first question flashes into view.
    private func announceSection(at index: Int, swappingContent: Bool) {
        guard session.sections.indices.contains(index) else { return }

        announcedSectionIndex = index
        interstitialTask?.cancel()
        interstitialTask = Task { [weak self] in
            guard let self else { return }

            if swappingContent {
                try? await Task.sleep(for: .seconds(self.announcementCoverDelay))
                guard !Task.isCancelled else { return }

                self.direction = .forward
                self.sectionIndex = index
                self.itemIndex = 0
                self.questionStep += 1
                self.handleQuestionChange()
            }

            try? await Task.sleep(for: .seconds(self.announcementHold))
            guard !Task.isCancelled else { return }

            self.announcedSectionIndex = nil
            self.startSection()
        }
    }

    private func finalize() {
        guard !isFinalized else { return }
        isFinalized = true

        history.record(ExamAttempt.attempts(from: session))
        pointsDelta = applyScore(passed: session.isPassed)

        haptic.notification(type: session.isPassed ? .success : .error)
        sound.playSound(session.isPassed ? .success : .answer(isCorrect: false))
        showResults = true
    }

    private func applyScore(passed: Bool) -> Int {
        let event: ScoreEvent
        switch session.mode {
        case .full:
            event = passed ? .examPassed : .examFailed
        case .single:
            event = passed ? .sectionExamPassed : .sectionExamFailed
        }

        score.award(event)
        return event.points
    }

    private func recordSectionMistakes(_ section: ExamSection) {
        for id in section.wrongAnsweredQuestionIDs {
            repository.recordPracticeMistake(questionID: id)
        }
    }

    // Two-phase move: a transition sticks to the view it was created with,
    // so the outgoing question must re-render with the new direction BEFORE
    // the id change removes it — otherwise the first slide after a direction
    // change (or after entering the screen) plays backwards.
    private func move(by delta: Int, direction newDirection: ExamNavigationDirection) {
        // Debounce: mashing the arrows outruns the slide animation and makes
        // questions flicker past without the user reading them.
        let now = Date()
        guard now.timeIntervalSince(lastMoveAt) >= minMoveInterval else { return }
        lastMoveAt = now

        haptic.impact()
        direction = newDirection

        Task { [weak self] in
            guard let self, self.isSectionRunning else { return }

            let target = self.itemIndex + delta
            guard self.currentSection.items.indices.contains(target) else { return }

            self.itemIndex = target
            self.questionStep += 1
            self.handleQuestionChange()
        }
    }

    private func label(forSectionAt index: Int) -> String {
        switch session.mode {
        case .full:
            return L10n("Exam.Session.section \(index + 1) \(session.sections.count)")
        case .single:
            return session.sections[index].categoryName
        }
    }

    private func handleQuestionChange() {
        prepareImages()
        refreshSavedState()
    }

    private func prepareImages() {
        let upcoming = currentSection.items[itemIndex...]
            .prefix(3)
            .map(\.question)

        MediaStore.shared.prepareImages(for: upcoming)
    }
}

// MARK: - ExamNavigationDirection
enum ExamNavigationDirection {
    case forward
    case backward
}

// MARK: - ExamResultRow
struct ExamResultRow: Identifiable {
    let id: String
    let title: String
    let score: String
    let isPassed: Bool
}
