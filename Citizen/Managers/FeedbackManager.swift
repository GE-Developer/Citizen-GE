//
//  FeedbackManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class FeedbackManager {
    private(set) var message: ToastMessage?
    
    private var clearTask: Task<Void, Never>?
    
    static let shared = FeedbackManager()
    
    private let visibleDuration: TimeInterval = 2.5
    
    private init() {}
    
    func show(_ text: String, style: ToastStyle) {
        clearTask?.cancel()
        message = ToastMessage(text: text, style: style)
        
        clearTask = Task {
            try? await Task.sleep(for: .seconds(visibleDuration))
            guard !Task.isCancelled else { return }
            message = nil
        }
    }
}

struct ToastMessage: Equatable, Identifiable {
    let id = UUID()
    let text: String
    let style: ToastStyle
}

enum ToastStyle {
    case success
    case info
    case error
}
