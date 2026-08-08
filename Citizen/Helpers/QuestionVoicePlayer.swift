//
//  QuestionVoicePlayer.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class QuestionVoicePlayer {
    var isEnabled: Bool {
        voiceActing.isVoiceActingOn
    }
    
    private(set) var playingPart: QuestionVoicePart?
    
    private var playbackTask: Task<Void, Never>?
    
    private let voiceActing = VoiceActingManager.shared
    
    func play(part: QuestionVoicePart?, file: String?, announceUnavailable: Bool = true) {
        guard isEnabled else { return }
        playbackTask?.cancel()
        
        playingPart = part
        
        playbackTask = Task { [weak self] in
            guard let self else { return }
            let duration = await voiceActing.playWhenReady(
                .questionAudio,
                fileName: file,
                announceUnavailable: announceUnavailable
            )
            
            guard !Task.isCancelled else { return }
            guard duration > 0, part != nil else {
                self.playingPart = nil
                return
            }
            
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self.playingPart = nil
        }
    }
    
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        playingPart = nil
        voiceActing.stop()
    }
}
