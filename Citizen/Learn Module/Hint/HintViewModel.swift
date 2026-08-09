//
//  HintViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class HintViewModel {
    var selectedWord: WordEntry?
    var showCorrectAnswer = false
    var showSaveSheet = false
    
    private(set) var isQuestionSaved = false
    
    var showsVoiceButtons: Bool {
        voice.isEnabled
    }
    
    var hasExplanations: Bool {
        !explanations.isEmpty
    }
    
    let question: Question
    let subTitle: String
    let questionSegments: [RichTextSegment]
    let questionTranslation: String?
    let sentenceSegments: [RichTextSegment]
    let sentenceTranslationSegments: [RichTextSegment]?
    let hasSentence: Bool
    let answerRows: [HintAnswerRow]
    let explanations: [String]
    
    let title = L10n("Hint.title")
    let questionHeader = L10n("Hint.questionHeader")
    let sentenceHeader = L10n("Hint.sentenceHeader")
    let explanationsHeader = L10n("Hint.explanationsHeader")
    let answersHeader = L10n("Hint.answersHeader")
    let saveButtonTitle = L10n("Hint.WordDetail.saveButton")
    let savedButtonTitle = L10n("Hint.WordDetail.savedButton")
    let showAnswerTitle = L10n("Hint.showAnswer")
    
    private let dictionary = WordsDictionary.shared
    private let store = SavedWordsStore.shared
    private let savedQuestions = SavedQuestionsStore.shared
    private let haptic = HapticsManager.shared
    private let voice = QuestionVoicePlayer()
    
    init(question: Question) {
        self.question = question
        self.subTitle = question.number
        self.questionSegments = question.question.asRichSegments
        
        let additional = question.additionalText ?? ""
        
        self.hasSentence = !additional.isEmpty
        self.sentenceSegments = additional.asRichSegments
        
        let translated = QuizRepository.shared.translation(forID: question.id)
        
        self.questionTranslation = translated?.question
        self.sentenceTranslationSegments = translated?.additionalText?.asRichSegments
        self.explanations = (translated ?? question).explanations
        
        let answerTranslations = Dictionary(
            (translated?.answers ?? []).map { ($0.label, $0.text) },
            uniquingKeysWith: { first, _ in first }
        )
        
        self.answerRows = question.answers.map { answer in
            HintAnswerRow(
                label: answer.label,
                text: answer.text,
                segments: answer.text.asRichSegments,
                translation: answerTranslations[answer.label],
                isCorrect: answer.isCorrect,
                audioUrl: answer.audioUrl,
                imageUrl: answer.imageUrl
            )
        }
        
        refreshSavedState()
    }
    
    func bookmarkButtonPressed() {
        haptic.impact()
        showSaveSheet = true
    }
    
    func playQuestion() {
        haptic.impact(style: .light)
        voice.play(part: nil, file: question.audioUrl)
    }
    
    func playSentence() {
        haptic.impact(style: .light)
        voice.play(part: nil, file: question.additionalAudioUrl)
    }
    
    func playAnswer(_ row: HintAnswerRow) {
        haptic.impact(style: .light)
        voice.play(part: nil, file: row.audioUrl)
    }
    
    func stopVoice() {
        voice.stop()
    }
    
    func refreshSavedState() {
        isQuestionSaved = savedQuestions.contains(question.id)
    }
    
    func selectWord(_ token: String) {
        guard var entry = dictionary.entry(for: token) else { return }
        entry.isSaved = store.contains(entry.key)
        selectedWord = entry
    }
    
    func transliterationText(_ value: String) -> String {
        "[\(value)]"
    }
    
    func toggleSave() {
        guard var detail = selectedWord else { return }
        detail.isSaved = store.toggle(detail.key)
        selectedWord = detail
        haptic.selectionChanged()
    }
}
