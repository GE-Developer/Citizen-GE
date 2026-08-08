//
//  SoundManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import AVFoundation

@MainActor
final class SoundManager {
    var isSoundOn: Bool {
        didSet { defaults.set(isSoundOn, forKey: key) }
    }
    
    static let shared = SoundManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.sound.key
    private var player: AVAudioPlayer?
    
    private init() {
        isSoundOn = defaults.object(forKey: key) as? Bool ?? true
        configureAudioSession()
    }
    
    func reset() {
        isSoundOn = true
    }
    
    func playSound(_ soundName: Sound) {
        guard isSoundOn else { return }
        
        let url = Bundle.main.url(forResource: soundName.name, withExtension: "mp3")
        guard let url else { return }
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    }
    
    private func configureAudioSession() {
        try? AVAudioSession
            .sharedInstance()
            .setCategory(.ambient, options: [.mixWithOthers])
        
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
