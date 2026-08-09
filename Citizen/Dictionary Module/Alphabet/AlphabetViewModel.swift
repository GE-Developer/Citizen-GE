//
//  AlphabetViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class AlphabetViewModel {
    var selectedLetter: AlphabetLetter?
    var showTranscription = true
    var letterNumberText: String {
        guard let selectedLetter else { return "" }
        return "\(selectedLetter.id) / \(letters.count)"
    }
    
    private(set) var isPlaying = false
    
    private var playbackTask: Task<Void, Never>?
    
    let showPlayButton: Bool
    let title = L10n("Alphabet.title")
    let allLettersTitle = L10n("Alphabet.Letters.header")
    let transcriptionToggleTitle = L10n("Alphabet.Transcription.title")
    let letters: [AlphabetLetter]
    
    private let voiceActingManager = VoiceActingManager.shared
    private let hapticManager = HapticsManager.shared
    
    init() {
        letters = AlphabetCatalog.shared.letters
        selectedLetter = letters.first
        showPlayButton = voiceActingManager.isVoiceActingOn
    }
    
    func select(_ letter: AlphabetLetter) {
        hapticManager.impact(style: .light)
        selectedLetter = letter
    }
    
    func playWord(_ letter: AlphabetLetter) {
        hapticManager.impact()
        playbackTask?.cancel()
        playbackTask = Task { [weak self] in
            guard let self else { return }
            let duration = await voiceActingManager.play(
                .alphabetExampleAudio,
                fileName: letter.exampleAudio
            )
            guard !Task.isCancelled else { return }
            guard duration > 0 else {
                isPlaying = false
                return
            }
            isPlaying = true
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            isPlaying = false
        }
    }
    
    func playLetter(_ letter: AlphabetLetter) {
        Task {
            await voiceActingManager.play(.alphabetLetterAudio, fileName: letter.letterAudio)
        }
    }
    
    func stopVoice() {
        playbackTask?.cancel()
        playbackTask = nil
        isPlaying = false
        voiceActingManager.stop()
    }
    
    func isSelected(_ letter: AlphabetLetter) -> Bool {
        letter.id == selectedLetter?.id
    }
    
    func transliteration(for letter: AlphabetLetter) -> String {
        "[\(letter.transliteration)]"
    }
    
    func exampleTransliteration(for letter: AlphabetLetter) -> String {
        "[\(letter.exampleWordTransliteration)]"
    }
}
