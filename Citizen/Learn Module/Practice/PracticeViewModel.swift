//
//  PracticeViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class PracticeViewModel: ObservableObject {
    @Published var chosenAnswer: Answer?
    @Published var showHint = false
    @Published var showRestartAlert = false
    @Published var showSaveSheet = false
    
    @Published private(set) var currentQuestion: Question
    @Published private(set) var isCurrentQuestionSaved = false
    @Published private(set) var sessionQuestions: [Question]
    @Published private(set) var sessionMistakes: [Question] = []
    @Published private(set) var displayedAnswers: [Answer] = []
    @Published private(set) var showsAnswerLabels = true
    @Published private(set) var questionStep = 0
    @Published private(set) var correctCount = 0
    @Published private(set) var roundsCompleted = 0
    @Published private(set) var showSubView = false
    @Published private(set) var showPreview = false
    @Published private(set) var isCompleted = false
    @Published private(set) var feedbackText = ""
    
    var subtitle: String {
        currentQuestion.number
    }
    
    var playingVoicePart: QuestionVoicePart? {
        voice.playingPart
    }
    
    var voicePlaybackID: Int {
        voice.playbackGeneration
    }
    
    var isVoiceActingEnabled: Bool {
        !isMistakeReview && voice.isEnabled
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
        L10n("Questions.counter \(sessionPosition) \(questionsCount)")
    }
    
    var additionalTextSegments: [RichTextSegment] {
        sentenceSegments(for: currentQuestion)
    }
    
    var previewProgress: Double {
        Double(correctCount) / Double(max(questionsCount, 1))
    }
    
    var ringCaption: String {
        L10n("Questions.Preview.ringCaption \(correctCount) \(questionsCount)")
    }
    
    var previewMistakes: [Question] {
        sessionQuestions.filter { $0.status == .wrong }
    }
    
    var statusBadgeText: String {
        isCompleted
        ? L10n("Practice.Status.completed")
        : L10n("TopicPhase.Status.workingOnMistakes")
    }
    
    var primaryActionTitle: String {
        isCompleted
        ? completedActionTitle
        : L10n("\(previewMistakes.count) TopicPhase.Action.workingOnMistakes")
    }
    
    var showsRestartButton: Bool {
        !isMistakeReview
    }
    
    var showsRoundsStat: Bool {
        !isMistakeReview
    }
    
    var showsHintButton: Bool {
        !isMistakeReview
    }
    
    var totalQuestionsText: String {
        "\(questionsCount)"
    }
    
    var mistakesCountText: String {
        "\(sessionMistakes.count)"
    }
    
    var roundsCompletedText: String {
        "\(roundsCompleted)"
    }
    
    private var sessionPosition: Int {
        (sessionQuestions.firstIndex { $0.id == currentQuestion.id } ?? 0) + 1
    }
    
    private var pendingQuestions: [Question]
    private var roundSize: Int
    private var visitedInRound = 0
    private var mistakeIDs: Set<String> = []
    private var isWorkingOnMistakes = false
    
    let headerTitle: String
    let screenTitle = L10n("Questions.title")
    let selectAnswerTitle = L10n("Questions.Button.selectAnswer")
    let checkAnswerTitle = L10n("Questions.Button.checkAnswer")
    let continueButtonTitle = L10n("Questions.Button.continue")
    let restartTitle = L10n("Questions.Preview.Restart.title")
    let restartAlertTitle = L10n("Questions.Preview.RestartAlert.title")
    let restartAlertMessage = L10n("Questions.Preview.RestartAlert.message")
    let restartAlertConfirmTitle = L10n("Questions.Preview.RestartAlert.confirm")
    let restartAlertCancelTitle = L10n("Questions.Preview.RestartAlert.cancel")
    let exitTitle = L10n("Questions.Preview.exit")
    let toReviewHeaderText = L10n("Questions.Preview.mistakesHeader")
    let completedTitle = L10n("Practice.Completed.title")
    let completedMessageText = L10n("Practice.Completed.message")
    let completedActionTitle = L10n("TopicPhase.Action.completed")
    let totalLabel = L10n("Main.Questions.title")
    let mistakesLabel = L10n("Practice.Stats.mistakes")
    let roundsLabel = L10n("Practice.Stats.rounds")
    
    private let sourceQuestions: [Question]
    private let questionsCount: Int
    private let isMistakeReview: Bool
    private let haptic = HapticsManager.shared
    private let sound = SoundManager.shared
    private let voice = QuestionVoicePlayer()
    private let shuffleManager = ShuffleAnswersManager.shared
    private let shuffleQuestionsManager = ShuffleQuestionsManager.shared
    private let repository = QuizRepository.shared
    private let savedStore = SavedQuestionsStore.shared
    private let score = ScoreManager.shared
    
    init(questions: [Question], title: String, isMistakeReview: Bool = false) {
        let normalized = questions.map { question -> Question in
            var copy = question
            copy.status = .unanswered
            return copy
        }
        
        let ordered = ShuffleQuestionsManager.shared.isShuffleQuestionsOn
        ? normalized.shuffled()
        : normalized
        
        headerTitle = title
        sourceQuestions = normalized
        questionsCount = normalized.count
        self.isMistakeReview = isMistakeReview
        sessionQuestions = ordered
        pendingQuestions = ordered
        currentQuestion = ordered[0]
        roundSize = ordered.count
        
        updateDisplayedAnswers()
    }
    
    func optionChanged(_ answer: Answer) {
        guard displayedAnswers.contains(answer),
              chosenAnswer != answer,
              !showSubView else { return }
        
        haptic.selectionChanged()
        chosenAnswer = answer
        playVoice(part: nil, file: answer.audioUrl, announceUnavailable: false)
    }
    
    func questionTapped() {
        playVoice(part: .question, file: currentQuestion.audioUrl)
    }
    
    func sentenceTapped() {
        playVoice(part: .sentence, file: currentQuestion.additionalAudioUrl)
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
    
    func continuePractice() {
        showPreview = false
    }
    
    func restartButtonPressed() {
        haptic.impact()
        showRestartAlert = true
    }
    
    func restartSession() {
        stopVoice()
        let ordered = shuffleQuestionsManager.isShuffleQuestionsOn
        ? sourceQuestions.shuffled()
        : sourceQuestions
        
        sessionQuestions = ordered
        pendingQuestions = ordered
        currentQuestion = ordered[0]
        correctCount = 0
        questionStep = 0
        roundsCompleted = 0
        chosenAnswer = nil
        showSubView = false
        feedbackText = ""
        isCompleted = false
        showPreview = false
        sessionMistakes = []
        mistakeIDs = []
        roundSize = ordered.count
        visitedInRound = 0
        isWorkingOnMistakes = false
        
        updateDisplayedAnswers()
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
    
    func sentenceSegments(for question: Question) -> [RichTextSegment] {
        (question.additionalText ?? "").asRichSegments
    }
    
    func mistakeRowTitle(for question: Question) -> String {
        L10n("Questions.Preview.mistakeRowTitle \(question.number)")
    }
    
    private func answer() {
        guard let chosen = chosenAnswer else { return }
        
        if !chosen.isCorrect {
            repository.recordPracticeMistake(questionID: currentQuestion.id)
        }
        setSessionStatus(chosen.isCorrect ? .correct : .wrong, forID: currentQuestion.id)
        
        if isMistakeReview,
           chosen.isCorrect,
           !mistakeIDs.contains(currentQuestion.id) {
            repository.resolveMistake(questionID: currentQuestion.id)
        }
        
        if !isMistakeReview, chosen.isCorrect {
            score.award(.practiceSolved)
        }
        
        if !chosen.isCorrect,
           mistakeIDs.insert(currentQuestion.id).inserted,
           let source = sourceQuestions.first(where: { $0.id == currentQuestion.id }) {
            sessionMistakes.append(source)
        }
        
        showSubView = true
        feedbackText = FeedbackPhrase.random(correct: chosen.isCorrect)
        haptic.notification(type: chosen.isCorrect ? .success : .error)
        sound.playSound(.answer(isCorrect: chosen.isCorrect))
    }
    
    private func playVoice(
        part: QuestionVoicePart?,
        file: String?,
        announceUnavailable: Bool = true
    ) {
        guard isVoiceActingEnabled else { return }
        voice.play(part: part, file: file, announceUnavailable: announceUnavailable)
    }
    
    private func next() {
        guard let chosen = chosenAnswer else { return }
        
        stopVoice()
        
        if chosen.isCorrect {
            correctCount += 1
            pendingQuestions.removeFirst()
        } else {
            let question = pendingQuestions.removeFirst()
            if !isMistakeReview {
                pendingQuestions.append(question)
            }
        }
        
        visitedInRound += 1
        
        chosenAnswer = nil
        showSubView = false
        feedbackText = ""
        
        if pendingQuestions.isEmpty {
            roundsCompleted += 1
            isCompleted = true
            showPreview = true
            return
        }
        
        if visitedInRound >= roundSize {
            roundsCompleted += 1
            roundSize = pendingQuestions.count
            visitedInRound = 0
            questionStep += 1
            currentQuestion = pendingQuestions[0]
            updateDisplayedAnswers()
            
            if !isWorkingOnMistakes {
                isWorkingOnMistakes = true
                showPreview = true
            }
            
            return
        }
        
        questionStep += 1
        currentQuestion = pendingQuestions[0]
        updateDisplayedAnswers()
    }
    
    private func setSessionStatus(_ status: AnswerStatus, forID id: String) {
        guard let index = sessionQuestions.firstIndex(where: { $0.id == id }) else { return }
        sessionQuestions[index].status = status
    }
    
    private func updateDisplayedAnswers() {
        let isShuffleOn = shuffleManager.isShuffleAnswersOn
        showsAnswerLabels = !isShuffleOn
        displayedAnswers = isShuffleOn
        ? currentQuestion.answers.shuffled()
        : currentQuestion.answers
        refreshSavedState()
        MediaStore.shared.prepareImages(for: [currentQuestion] + pendingQuestions.prefix(2))
    }
}
