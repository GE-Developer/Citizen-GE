//
//  ResetPasswordViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ResetPasswordViewModel {
    var code = "" {
        didSet {
            let sanitized = AuthValidator.sanitizeCode(code, length: codeLength)
            if sanitized != code {
                code = sanitized
            }
        }
    }
    
    var newPassword = ""
    var confirmPassword = ""
    
    var isCodeComplete: Bool {
        code.count == codeLength
    }
    
    var isSubmitDisabled: Bool {
        guard !isLoading else { return true }
        let passwordValid = newPassword.count >= AuthValidator.minPasswordLength
        
        return !(isCodeComplete && passwordValid && confirmPassword == newPassword)
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
    let subtitle = L10n("Auth.Reset.subtitle")
    let codeLabel = L10n("Auth.Confirm.codePlaceholder")
    let newPasswordLabel = L10n("Auth.Password.create")
    let confirmPasswordLabel = L10n("Auth.ConfirmPassword.placeholder")
    let submitTitle = L10n("Auth.Confirm.button")
    let resendTitle = L10n("Auth.Confirm.resend")
    let codeLength = 6
    
    private let countdown = ResendCountdown()
    private let resendInTitle = L10n("Auth.Confirm.resendIn")
    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared
    private let feedback = FeedbackManager.shared
    
    init(email: String) {
        self.email = email
    }
    
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        countdown.start()
    }
    
    // Отправка нового пароля.
    func submit() async {
        guard !isLoading else { return }
        
        if let error = validationError() {
            showError(error)
            return
        }
        
        haptics.impact()
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await auth
                .resetPassword(email: email, code: code, newPassword: newPassword)
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
            try await auth
                .requestPasswordReset(email: email)
            countdown.start()
        } catch {
            showError(error.message)
        }
    }
    
    private func validationError() -> String? {
        let result = AuthValidator.validate(
            email: email,
            password: newPassword,
            confirmPassword: confirmPassword
        )
        
        let messages = [result.passwordError?.message, result.confirmError?.message]
            .compactMap { $0 }
        
        return messages.isEmpty ? nil : messages.joined(separator: "\n")
    }
    
    private func showError(_ message: String) {
        haptics.impact()
        feedback.show(message, style: .error)
    }
}
