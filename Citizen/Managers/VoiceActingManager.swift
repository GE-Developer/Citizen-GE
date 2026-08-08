//
//  VoiceActingManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import AVFoundation
import Observation

@MainActor
@Observable
final class VoiceActingManager {
    var isVoiceActingOn: Bool {
        didSet { defaults.set(isVoiceActingOn, forKey: key) }
    }
    
    private(set) var unavailableNotice: String?
    
    private var restoreSessionTask: Task<Void, Never>?
    private var noticeTask: Task<Void, Never>?
    
    static let shared = VoiceActingManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.voiceActing.key
    private let mediaStore = MediaStore.shared
    private let playback = AudioPlayback()
    
    private let notDownloadedNotice = L10n("VoiceActing.Unavailable.notDownloaded")
    private let missingNotice = L10n("VoiceActing.Unavailable.missing")
    
    private init() {
        isVoiceActingOn = defaults.object(forKey: key) as? Bool ?? true
    }
    
    func reset() {
        isVoiceActingOn = true
    }
    
    @discardableResult
    func play(_ kind: MediaKind, fileName: String?) async -> TimeInterval {
        guard isVoiceActingOn else { return 0 }
        
        guard let fileName, !fileName.isEmpty else {
            showNotice(missingNotice)
            
            return 0
        }
        
        guard let url = localOrBundledURL(kind, fileName: fileName) else {
            showNotice(notDownloadedNotice)
            Task {
                _ = try? await mediaStore.fetch(kind, name: fileName)
            }
            
            return 0
        }
        
        return await startPlaying(url)
    }
    
    @discardableResult
    func playWhenReady(
        _ kind: MediaKind,
        fileName: String?,
        announceUnavailable: Bool = true
    ) async -> TimeInterval {
        guard isVoiceActingOn else { return 0 }
        
        guard let fileName, !fileName.isEmpty else {
            if announceUnavailable {
                showNotice(missingNotice)
            }
            
            return 0
        }
        
        if localOrBundledURL(kind, fileName: fileName) == nil {
            _ = try? await mediaStore.fetch(kind, name: fileName)
        }
        
        guard !Task.isCancelled else { return 0 }
        
        guard let url = localOrBundledURL(kind, fileName: fileName) else {
            if announceUnavailable {
                showNotice(notDownloadedNotice)
            }
            
            return 0
        }
        
        return await startPlaying(url)
    }
    
    func stop() {
        restoreSessionTask?.cancel()
        
        Task { [playback] in
            await playback.stop()
        }
        
        scheduleSessionRestore(after: 0)
    }
    
    private func startPlaying(_ url: URL) async -> TimeInterval {
        restoreSessionTask?.cancel()
        
        let duration = await playback.play(url)
        
        scheduleSessionRestore(after: duration)
        
        return duration
    }
    
    private func localOrBundledURL(_ kind: MediaKind, fileName: String) -> URL? {
        if let url = mediaStore.localURL(kind, name: fileName) {
            return url
        }
        
        let ns = fileName as NSString
        let ext = ns.pathExtension.isEmpty ? "mp3" : ns.pathExtension
        
        return Bundle.main.url(forResource: ns.deletingPathExtension, withExtension: ext)
    }
    
    private func showNotice(_ text: String) {
        noticeTask?.cancel()
        unavailableNotice = text
        noticeTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            unavailableNotice = nil
        }
    }
    
    private func scheduleSessionRestore(after duration: TimeInterval) {
        restoreSessionTask = Task { [playback] in
            try? await Task.sleep(for: .seconds(duration + 0.2))
            guard !Task.isCancelled else { return }
            await playback.restoreAmbientSessionIfIdle()
        }
    }
}

// MARK: - AudioPlayback
private actor AudioPlayback {
    private var player: AVAudioPlayer?
    
    func play(_ url: URL) -> TimeInterval {
        activatePlaybackSession()
        player?.stop()
        
        guard let newPlayer = try? AVAudioPlayer(contentsOf: url) else {
            player = nil
            
            return 0
        }
        
        player = newPlayer
        newPlayer.prepareToPlay()
        newPlayer.play()
        
        return newPlayer.duration
    }
    
    func stop() {
        player?.stop()
    }
    
    func restoreAmbientSessionIfIdle() {
        guard player?.isPlaying != true else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
    }
    
    private func activatePlaybackSession() {
        try? AVAudioSession
            .sharedInstance()
            .setCategory(.playback, options: [.mixWithOthers])
    }
}
