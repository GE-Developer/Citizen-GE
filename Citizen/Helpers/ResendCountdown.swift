//
//  ResendCountdown.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ResendCountdown {
    var isFinished: Bool {
        remaining == 0
    }
    
    private(set) var remaining = 0
    
    private var deadline: Date?
    private var tickTask: Task<Void, Never>?
    
    private let cooldown: TimeInterval = 60
    
    func start() {
        deadline = Date().addingTimeInterval(cooldown)
        refreshRemaining()
        tickTask?.cancel()
        
        tickTask = Task { [weak self] in
            while let self, self.remaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                
                if Task.isCancelled {
                    return
                }
                
                self.refreshRemaining()
            }
        }
    }
    
    private func refreshRemaining() {
        guard let deadline else {
            remaining = 0
            return
        }
        
        remaining = max(0, Int(deadline.timeIntervalSinceNow.rounded(.up)))
    }
}
