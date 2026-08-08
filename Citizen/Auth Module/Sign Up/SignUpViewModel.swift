//
//  SignUpViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class SignUpViewModel {
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    
    var isSubmitDisabled: Bool {
        guard !isLoading else { return true }
        
        let nameValid = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailValid = AuthValidator.isValidEmail(AuthValidator.normalizeEmail(email))
        let passwordValid = password.count >= AuthValidator.minPasswordLength
        
        return !(nameValid && emailValid && passwordValid && confirmPassword == password)
    }
    
    private(set) var isLoading = false
    
    let title = L10n("Auth.SignUp.title")
    let subtitle = L10n("Auth.SignUp.subtitle")
    let submitTitle = L10n("Auth.SignUp.button")
    let nameLabel = L10n("Settings.Account.Nickname.title")
    let emailLabel = L10n("Auth.Email.placeholder")
    let emailPlaceholder = L10n("Auth.Email.example")
    let passwordLabel = L10n("Auth.Password.placeholder")
    let createPasswordPlaceholder = L10n("Auth.Password.create")
    let repeatPasswordLabel = L10n("Auth.ConfirmPassword.placeholder")
    
    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared
    private let feedback = FeedbackManager.shared
    
    func submit() async -> (email: String, name: String?)? {
        guard !isLoading else { return nil }
        
        if let error = validationError() {
            showError(error)
            return nil
        }
        
        haptics.impact()
        isLoading = true
        
        defer { isLoading = false }
        
        let normalizedEmail = AuthValidator.normalizeEmail(email)
        let userName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try await auth
                .signUp(email: normalizedEmail, password: password, nickname: userName)
            
            return auth.isAuthenticated ? nil : (normalizedEmail, userName)
        } catch {
            showError(error.message)
            return nil
        }
    }
    
    private func validationError() -> String? {
        let result = AuthValidator.validate(
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        let nameIsEmpty = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let messages = [
            nameIsEmpty ? AuthFieldError.emptyName.message : nil,
            result.emailError?.message,
            result.passwordError?.message,
            result.confirmError?.message
        ].compactMap { $0 }
        
        return messages.isEmpty ? nil : messages.joined(separator: "\n")
    }
    
    private func showError(_ message: String) {
        haptics.impact()
        feedback.show(message, style: .error)
    }
}
