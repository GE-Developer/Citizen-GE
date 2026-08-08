//
//  LeaderboardStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class LeaderboardStore {
    private(set) var entries: [LeaderboardEntry]
    
    static let shared = LeaderboardStore()
    
    private init() {
        entries = Self.readFromDisk()
    }
    
    func save(_ entries: [LeaderboardEntry]) {
        self.entries = entries
        writeToDisk(entries)
    }
    
    func wipe() {
        try? FileManager.default.removeItem(at: Self.fileURL)
        entries = []
    }
    
    func refresh() async throws {
        let fresh = try await LeaderboardService.shared.fetchTop()
        save(fresh)
    }
    
    private func writeToDisk(_ entries: [LeaderboardEntry]) {
        let url = Self.fileURL
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(entries)
            try data.write(to: url, options: .atomic)
        } catch {
        }
    }
    
    nonisolated private static var fileURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Leaderboard")
            .appendingPathComponent("leaderboard.json")
    }
    
    nonisolated private static func readFromDisk() -> [LeaderboardEntry] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([LeaderboardEntry].self, from: data)) ?? []
    }
}
