//
//  AlphabetCatalog.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class AlphabetCatalog {
    private(set) var letters: [AlphabetLetter] = []
    
    static let shared = AlphabetCatalog()
    
    private init() {}
    
    func load() async throws {
        guard letters.isEmpty else { return }
        
        letters = try await Task.detached(priority: .userInitiated) {
            try Self.decode()
        }.value
    }
    
    private nonisolated static func decode() throws -> [AlphabetLetter] {
        guard let data = ResourceProvider.shared.data(forName: "alphabet") else {
            throw ResourceError.loadFailed("alphabet")
        }
        do {
            return try JSONDecoder().decode([AlphabetLetter].self, from: data)
        } catch {
            throw ResourceError.loadFailed("alphabet")
        }
    }
}
