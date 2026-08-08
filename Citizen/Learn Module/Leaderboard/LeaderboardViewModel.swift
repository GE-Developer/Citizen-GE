//
//  LeaderboardViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class LeaderboardViewModel {
    enum Phase {
        case loading
        case loaded
        case failed
    }
    
    var myRankText: String? {
        guard let currentUserID,
              let index = entries.firstIndex(where: { $0.id == currentUserID })
        else { return nil }
        return "\(index + 1)"
    }
    
    private(set) var phase: Phase = .loading
    private(set) var entries: [LeaderboardEntry] = []
    
    let title = L10n("Main.Leaderboard.title")
    let rankSuffix = L10n("Main.Leaderboard.rankSuffix")
    let failureTitle = L10n("Error.title")
    
    private let currentUserID = AuthManager.shared.userID
    private let store = LeaderboardStore.shared
    
    init() {
        entries = store.entries
        phase = entries.isEmpty ? .loading : .loaded
    }
    
    func load() async {
        if entries.isEmpty {
            phase = .loading
        }
        
        do {
            try await store.refresh()
            entries = store.entries
            phase = .loaded
        } catch {
            if entries.isEmpty {
                phase = .failed
            }
        }
    }
    
    func isCurrentUser(_ entry: LeaderboardEntry) -> Bool {
        entry.id == currentUserID
    }
    
    func rankText(for index: Int) -> String {
        "\(index + 1)"
    }
    
    func nicknameText(_ entry: LeaderboardEntry) -> String {
        entry.nickname ?? "-"
    }
    
    func scoreText(_ entry: LeaderboardEntry) -> String {
        "\(entry.scores)"
    }
    
    func mood(_ entry: LeaderboardEntry) -> Mood? {
        guard let mood = entry.mood, !mood.isEmpty else { return nil }
        return Mood(rawValue: mood)
    }
    
    func progressFraction(_ entry: LeaderboardEntry) -> Double {
        min(max(Double(entry.progressPercent), 0), 100) / 100
    }
}
