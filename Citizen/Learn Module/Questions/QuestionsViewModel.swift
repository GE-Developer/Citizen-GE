//
//  QuestionsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class QuestionsViewModel: ObservableObject {
    @Published var chosenAnswer: Answer?
    @Published var showHint = false
    @Published var showRestartAlert = false
    @Published var showSaveSheet = false
    
    @Published private(set) var currentQuestion: Question
    @Published private(set) var isCurrentQuestionSaved = false
    @Published private(set) var questionStep: Int = 0
    @Published private(set) var correctCount: Int
    @Published private(set) var showSubView = false
    @Published private(set) var showPreview: Bool
    @Published private(set) var feedbackText: String = ""
    @Published private(set) var phase: TopicPhase
    @Published private(set) var attempts: Int = 0
    @Published private(set) var sessionBestStreak: Int = 0
    @Published private(set) var successfulCompletions: Int = 0
    @Published private(set) var displayedAnswers: [Answer] = []
    @Published private(set) var showsAnswerLabels = true
    
    var progress: Double {
        Double(correctCount) / Double(max(questionsCount, 1))
    }
    
    var subtitle: String {
        currentQuestion.number
    }
    
    var playingVoicePart: QuestionVoicePart? {
        voice.playingPart
    }
    
    var isVoiceActingEnabled: Bool {
        voice.isEnabled
    }
    
    var allTopicQuestions: [Question] {
        repository.topic(byID: topicID)?.questions ?? []
    }
    
    var ctaTitle: String {
        if showSubView {
            return continueButtonTitle
        }
        
        if chosenAnswer == nil {
            return selectAnswerTitle
        }
        
        return checkAnswerTitle
    }
    
    var ctaEnabled: Bool {
        showSubView || chosenAnswer != nil
    }
    
    var bannerTitle: String {
        (chosenAnswer?.isCorrect ?? false)
        ? L10n("Questions.Banner.correct")
        : L10n("Questions.Banner.wrong")
    }
    
    var questionCounterText: String {
        L10n("Questions.counter \(currentQuestion.index) \(questionsCount)")
    }
    
    var additionalTextSegments: [RichTextSegment] {
        sentenceSegments(for: currentQuestion)
    }
    
    var bestStreakText: String {
        "\(sessionBestStreak)"
    }
    
    var attemptsText: String {
        "\(attempts)"
    }
    
    var successfulCompletionsText: String {
        "\(successfulCompletions)"
    }
    
    var headerSubtitle: String? {
        phase.statusLabel
    }
    
    var ringCaption: String {
        L10n("Questions.Preview.ringCaption \(correctCount) \(questionsCount)")
    }
    
    var wrongQuestions: [Question] {
        guard let topic = repository.topic(byID: topicID) else { return [] }
        return topic.questions.filter { $0.status == .wrong }
    }
    
    var primaryActionTitle: String {
        phase.primaryActionTitle(mistakesCount: mistakesCount) ?? ""
    }
    
    private var mistakesCount: Int { wrongQuestions.count }
    private var pendingQuestions: [Question]
    private var currentStreak: Int = 0
    private var roundSize: Int = 0
    private var visitedInRound: Int = 0
    private var didFinalizeCompletion = false
    
    let topicTitle: String
    let restartTitle = L10n("Questions.Preview.Restart.title")
    let restartSubtitle = L10n("Questions.Preview.Restart.subtitle")
    let restartAlertTitle = L10n("Questions.Preview.RestartAlert.title")
    let restartAlertMessage = L10n("Questions.Preview.RestartAlert.message")
    let restartAlertConfirmTitle = L10n("Questions.Preview.RestartAlert.confirm")
    let restartAlertCancelTitle = L10n("Questions.Preview.RestartAlert.cancel")
    let exitTitle = L10n("Questions.Preview.exit")
    let bestStreakLabel = L10n("Questions.Preview.Stats.bestStreak")
    let successfulCompletionsLabel = L10n("Questions.Preview.Stats.completed")
    let attemptsLabel = L10n("Questions.Preview.Stats.attempts")
    let toReviewHeaderText = L10n("Questions.Preview.mistakesHeader")
    let completedTitle = L10n("Questions.Preview.Completed.title")
    let completedMessageText = L10n("Questions.Preview.Completed.message")
    let selectAnswerTitle = L10n("Questions.Button.selectAnswer")
    let checkAnswerTitle = L10n("Questions.Button.checkAnswer")
    let continueButtonTitle = L10n("Questions.Button.continue")
    let testTitle = L10n("Questions.title")
    
    private let topicID: String
    private let questionsCount: Int
    private let haptic = HapticsManager.shared
    private let sound = SoundManager.shared
    private let voice = QuestionVoicePlayer()
    private let shuffleManager = ShuffleAnswersManager.shared
    private let repository = QuizRepository.shared
    private let statsStorage = TopicStatsStorage.shared
    private let savedStore = SavedQuestionsStore.shared
    private let score = ScoreManager.shared
    
    init(topic: Topic) {
        self.topicID = topic.id
        self.topicTitle = topic.name
        self.questionsCount = topic.questions.count
        
        let current = QuizRepository.shared.topic(byID: topic.id) ?? topic
        let questions = current.questions
        let phase = current.phase
        
        self.phase = phase
        self.correctCount = questions.count { $0.status == .correct }
        
        let stats = TopicStatsStorage.shared.fetch(topicID: topic.id)
        self.attempts = stats.attempts
        self.sessionBestStreak = stats.bestStreak
        self.successfulCompletions = stats.successfulCompletions
        
        switch phase {
        case .notStarted:
            self.showPreview = false
            self.pendingQuestions = questions
            self.currentQuestion = questions[0]
            self.roundSize = questions.count
            self.visitedInRound = 0
        case .completed:
            self.showPreview = true
            self.pendingQuestions = []
            self.currentQuestion = questions[0]
            self.roundSize = 0
            self.visitedInRound = 0
        case .workingOnMistakes:
            let wrongs = questions.filter { $0.status == .wrong }
            self.showPreview = true
            self.pendingQuestions = wrongs
            self.currentQuestion = wrongs[0]
            
            if stats.currentRoundSize > 0, stats.visitedInRound < stats.currentRoundSize {
                self.roundSize = stats.currentRoundSize
                self.visitedInRound = stats.visitedInRound
            } else {
                self.roundSize = wrongs.count
                self.visitedInRound = 0
            }
        case .inProgress:
            let unanswered = questions.filter { $0.status == .unanswered }
            let wrongs = questions.filter { $0.status == .wrong }
            let remaining = unanswered + wrongs
            self.showPreview = true
            self.pendingQuestions = remaining
            self.currentQuestion = remaining[0]
            self.roundSize = questions.count
            if stats.currentRoundSize == questions.count && stats.visitedInRound > 0 {
                self.visitedInRound = stats.visitedInRound
            } else {
                self.visitedInRound = (questions.count - unanswered.count)
            }
        }
        
        if stats.currentRoundSize == 0 && self.roundSize > 0 {
            TopicStatsStorage.shared.setRoundProgress(
                topicID: topic.id,
                roundSize: self.roundSize,
                visited: self.visitedInRound
            )
        }
        
        updateDisplayedAnswers()
    }
    
    func optionChanged(_ answer: Answer) {
        guard displayedAnswers.contains(answer),
              chosenAnswer != answer,
              !showSubView else { return }
        haptic.selectionChanged()
        chosenAnswer = answer
        voice.play(part: nil, file: answer.audioUrl, announceUnavailable: false)
    }
    
    func questionTapped() {
        voice.play(part: .question, file: currentQuestion.audioUrl)
    }
    
    func sentenceTapped() {
        voice.play(part: .sentence, file: currentQuestion.additionalAudioUrl)
    }
    
    func stopVoice() {
        voice.stop()
    }
    
    func buttonPressed() {
        showSubView ? next() : answer()
    }
    
    func hintButtonPressed() {
        haptic.impact()
        showHint = true
    }
    
    func bookmarkButtonPressed() {
        haptic.impact()
        showSaveSheet = true
    }
    
    func refreshSavedState() {
        isCurrentQuestionSaved = savedStore.contains(currentQuestion.id)
    }
    
    func continueTest() {
        showPreview = false
    }
    
    func restartButtonPressed() {
        haptic.impact()
        showRestartAlert = true
    }
    
    func restartTest() {
        voice.stop()
        repository.restartTopic(topicID)
        guard let fresh = repository.topic(byID: topicID) else { return }
        pendingQuestions = fresh.questions
        currentQuestion = fresh.questions[0]
        correctCount = 0
        questionStep = 0
        chosenAnswer = nil
        showSubView = false
        feedbackText = ""
        phase = .notStarted
        showPreview = false
        
        currentStreak = 0
        sessionBestStreak = 0
        attempts = 0
        didFinalizeCompletion = false
        
        roundSize = fresh.questions.count
        visitedInRound = 0
        
        statsStorage.resetAttemptStats(topicID: topicID)
        statsStorage.setRoundProgress(topicID: topicID, roundSize: roundSize, visited: visitedInRound)
        
        updateDisplayedAnswers()
    }
    
    func sentenceSegments(for question: Question) -> [RichTextSegment] {
        (question.additionalText ?? "").asRichSegments
    }
    
    func mistakeRowTitle(for question: Question) -> String {
        L10n("Questions.Preview.mistakeRowTitle \(question.number)")
    }
    
    func rowState(for answer: Answer) -> AnswerRowState {
        if !showSubView {
            return chosenAnswer == answer ? .selected : .idle
        }
        
        if answer.isCorrect && chosenAnswer == answer {
            return .correct
        }
        
        if answer.isCorrect {
            return .revealCorrect
        }
        
        if chosenAnswer == answer {
            return .wrong
        }
        
        return .idle
    }
    
    private func answer() {
        guard let chosen = chosenAnswer else { return }
        
        repository.recordAnswer(questionID: currentQuestion.id, isCorrect: chosen.isCorrect)
        statsStorage.setRoundProgress(
            topicID: topicID,
            roundSize: roundSize,
            visited: visitedInRound + 1
        )
        
        if phase == .notStarted || phase == .inProgress {
            if chosen.isCorrect {
                currentStreak += 1
                if currentStreak > sessionBestStreak {
                    sessionBestStreak = currentStreak
                    statsStorage.setBestStreak(topicID: topicID, value: sessionBestStreak)
                }
            } else {
                currentStreak = 0
            }
        }
        
        if chosen.isCorrect, pendingQuestions.count == 1 {
            finalizeCompletion()
        }
        
        showSubView = true
        feedbackText = FeedbackPhrase.random(correct: chosen.isCorrect)
        haptic.notification(type: chosen.isCorrect ? .success : .error)
        sound.playSound(.answer(isCorrect: chosen.isCorrect))
    }
    
    private func next() {
        guard let chosen = chosenAnswer else { return }
        
        voice.stop()
        
        if chosen.isCorrect {
            correctCount += 1
            pendingQuestions.removeFirst()
        } else {
            let q = pendingQuestions.removeFirst()
            pendingQuestions.append(q)
        }
        
        visitedInRound += 1
        persistRoundProgress()
        let phaseBefore = phase
        
        chosenAnswer = nil
        showSubView = false
        feedbackText = ""
        
        if pendingQuestions.isEmpty || visitedInRound >= roundSize {
            if pendingQuestions.isEmpty {
                phase = .completed
                finalizeCompletion()
                sound.playSound(.success)
                showPreview = true
                return
            }
            
            finishRound(completed: false)
            startNewRound()
            
            if phaseBefore == .notStarted || phaseBefore == .inProgress {
                phase = .workingOnMistakes
                questionStep += 1
                currentQuestion = pendingQuestions[0]
                updateDisplayedAnswers()
                showPreview = true
                return
            }
        }
        
        guard !pendingQuestions.isEmpty else { return }
        questionStep += 1
        currentQuestion = pendingQuestions[0]
        updateDisplayedAnswers()
    }
    
    private func finishRound(completed: Bool) {
        attempts += 1
        statsStorage.setAttempts(topicID: topicID, value: attempts)
        if completed {
            successfulCompletions += 1
            statsStorage.setSuccessfulCompletions(topicID: topicID, value: successfulCompletions)
        }
    }
    
    private func finalizeCompletion() {
        guard !didFinalizeCompletion else { return }
        didFinalizeCompletion = true
        finishRound(completed: true)
        score.award(.topicCompleted)
    }
    
    private func startNewRound() {
        roundSize = pendingQuestions.count
        visitedInRound = 0
        persistRoundProgress()
    }
    
    private func persistRoundProgress() {
        statsStorage.setRoundProgress(topicID: topicID, roundSize: roundSize, visited: visitedInRound)
    }
    
    private func updateDisplayedAnswers() {
        let isShuffleOn = shuffleManager.isShuffleAnswersOn
        showsAnswerLabels = !isShuffleOn
        displayedAnswers = isShuffleOn
        ? currentQuestion.answers.shuffled()
        : currentQuestion.answers
        refreshSavedState()
    }
}
