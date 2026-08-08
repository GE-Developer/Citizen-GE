//
//  SignInViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class SignInViewModel {
    var email = ""
    var password = ""
    
    var isSubmitDisabled: Bool {
        guard !isLoading else { return true }
        
        let emailValid = AuthValidator.isValidEmail(AuthValidator.normalizeEmail(email))
        let passwordValid = password.count >= AuthValidator.minPasswordLength
        
        return !(emailValid && passwordValid)
    }
    
    private(set) var isLoading = false
    
    let title = L10n("Auth.SignIn.title")
    let subtitle = L10n("Auth.SignIn.subtitle")
    let submitTitle = L10n("Auth.SignIn.button")
    let emailLabel = L10n("Auth.Email.placeholder")
    let emailPlaceholder = L10n("Auth.Email.example")
    let passwordLabel = L10n("Auth.Password.placeholder")
    let forgotPasswordTitle = L10n("Auth.forgotPassword")
    
    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared
    private let feedback = FeedbackManager.shared
    
    func submit() async -> String? {
        guard !isLoading else { return nil }
        
        if let error = validationError() {
            showError(error)
            return nil
        }

        haptics.impact()
        isLoading = true
        
        defer { isLoading = false }
        
        let normalizedEmail = AuthValidator.normalizeEmail(email)
        
        do {
            try await auth
                .signIn(email: normalizedEmail, password: password)
            return nil
        } catch {
            if case .emailNotConfirmed = error {
                haptics.impact()
                try? await auth
                    .resendSignUpCode(email: normalizedEmail)
                return normalizedEmail
            }
            showError(error.message)
            return nil
        }
    }
    
    func forgotPassword() async -> String? {
        guard !isLoading else { return nil }
        let normalizedEmail = AuthValidator.normalizeEmail(email)
        
        guard AuthValidator.isValidEmail(normalizedEmail) else {
            let fieldError: AuthFieldError = normalizedEmail.isEmpty ? .emptyEmail : .invalidEmail
            showError(fieldError.message)
            return nil
        }

        haptics.impact()
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await auth
                .requestPasswordReset(email: normalizedEmail)
            return normalizedEmail
        } catch {
            showError(error.message)
            return nil
        }
    }
    
    private func validationError() -> String? {
        let result = AuthValidator.validate(
            email: email,
            password: password,
            confirmPassword: nil
        )
        
        let messages = [result.emailError?.message, result.passwordError?.message]
            .compactMap { $0 }
        
        return messages.isEmpty ? nil : messages.joined(separator: "\n")
    }
    
    private func showError(_ message: String) {
        haptics.impact()
        feedback.show(message, style: .error)
    }
}
