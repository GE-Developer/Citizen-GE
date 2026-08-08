//
//  ScoreManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ScoreManager {
    private(set) var total: Int
    
    static let shared = ScoreManager()
    
    private let storage = ScoreStorage.shared
    
    private init() {
        total = storage.fetchTotal()
    }
    
    // MARK: - Public API
    func award(_ event: ScoreEvent) {
        let next = max(0, total + event.points)
        
        guard next != total else { return }
        
        total = next
        storage.setTotal(next)
    }
    
    func applyServer(total serverTotal: Int) {
        guard serverTotal != total else { return }
        
        total = serverTotal
        storage.setTotal(serverTotal)
    }
    
    func reset() {
        total = 0
        storage.reset()
    }
}
