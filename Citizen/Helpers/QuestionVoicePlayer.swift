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
    private var playbackGeneration = 0
    
    private let voiceActing = VoiceActingManager.shared
    
    func play(part: QuestionVoicePart?, file: String?, announceUnavailable: Bool = true) {
        guard isEnabled else {
            stop()
            return
        }
        
        playbackTask?.cancel()
        playbackGeneration &+= 1
        let generation = playbackGeneration
        
        playingPart = part
        
        playbackTask = Task { [weak self] in
            guard let self else { return }
            
            defer {
                if self.playbackGeneration == generation {
                    self.playingPart = nil
                }
            }
            
            let duration = await voiceActing.playWhenReady(
                .questionAudio,
                fileName: file,
                announceUnavailable: announceUnavailable
            )
            
            guard self.playbackGeneration == generation, duration > 0, part != nil else { return }
            
            try? await Task.sleep(for: .seconds(duration))
        }
    }
    
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        playbackGeneration &+= 1
        playingPart = nil
        voiceActing.stop()
    }
}
