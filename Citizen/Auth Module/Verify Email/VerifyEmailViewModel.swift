//
//  VerifyEmailViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class VerifyEmailViewModel {
    var code = "" {
        didSet {
            let sanitized = AuthValidator.sanitizeCode(code, length: codeLength)
            
            if sanitized != code {
                code = sanitized
            }
        }
    }
    
    var isCodeComplete: Bool {
        code.count == codeLength
    }
    
    var isVerifyDisabled: Bool {
        isLoading || !isCodeComplete
    }
    
    var showsResendButton: Bool {
        countdown.isFinished
    }
    
    var canResend: Bool {
        countdown.isFinished && !isLoading
    }
    
    var resendCountdownText: String {
        let time = String(format: "%02d:%02d", countdown.remaining / 60, countdown.remaining % 60)
        return "\(resendInTitle) \(time)"
    }
    
    private(set) var isLoading = false
    
    private var hasStarted = false
    
    let email: String
    let title = L10n("Auth.Confirm.title")
    let subtitle = L10n("Auth.Confirm.subtitle")
    let verifyTitle = L10n("Auth.Confirm.button")
    let resendTitle = L10n("Auth.Confirm.resend")
    let codeLength = 6
    
    private let name: String?
    private let countdown = ResendCountdown()
    private let resendInTitle = L10n("Auth.Confirm.resendIn")
    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared
    private let feedback = FeedbackManager.shared
    
    init(email: String, name: String?) {
        self.email = email
        self.name = name
    }
    
    func start() {
        guard !hasStarted else { return }
        
        hasStarted = true
        countdown.start()
    }
    
    func verify() async {
        guard !isLoading, isCodeComplete else { return }
        
        haptics.impact()
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await auth
                .verifyEmailOTP(email: email, token: code, nickname: name)
        } catch {
            showError(error.message)
        }
    }
    
    func resend() async {
        guard canResend else { return }
        
        haptics.impact()
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await auth.resendSignUpCode(email: email)
            countdown.start()
        } catch {
            showError(error.message)
        }
    }
    
    private func showError(_ message: String) {
        haptics.impact()
        feedback.show(message, style: .error)
    }
}
