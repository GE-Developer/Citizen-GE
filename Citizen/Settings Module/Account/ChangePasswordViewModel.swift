//
//  ChangePasswordViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ChangePasswordViewModel {
    var currentPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    
    var isSubmitDisabled: Bool {
        guard !isLoading else { return true }
        let passwordValid = newPassword.count >= AuthValidator.minPasswordLength
        let passwordChanged = newPassword != currentPassword
        return !(!currentPassword.isEmpty && passwordValid && passwordChanged && confirmPassword == newPassword)
    }
    
    private(set) var isLoading = false
    private(set) var didChangePassword = false
    
    let title = L10n("Settings.Account.ChangePassword.title")
    let currentPasswordLabel = L10n("Settings.Account.CurrentPassword.placeholder")
    let newPasswordLabel = L10n("Settings.Account.NewPassword.placeholder")
    let confirmPasswordLabel = L10n("Auth.ConfirmPassword.placeholder")
    let submitTitle = L10n("Saved.renameConfirm")
    
    private let wrongPasswordMessage = L10n("Settings.Account.ChangePassword.wrongPassword")
    private let passwordChangedMessage = L10n("Settings.Account.Feedback.passwordChanged")
    private let auth = AuthManager.shared
    private let feedback = FeedbackManager.shared
    private let haptics = HapticsManager.shared
    
    func submit() async {
        guard !isLoading else { return }
        
        if let error = validationError() {
            showError(error)
            return
        }
        
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await auth.changePassword(current: currentPassword, new: newPassword)
            haptics.notification(type: .success)
            feedback.show(passwordChangedMessage, style: .success)
            didChangePassword = true
        } catch {
            if case .invalidCredentials = error {
                showError(wrongPasswordMessage)
            } else {
                showError(error.message)
            }
        }
    }
    
    private func validationError() -> String? {
        let result = AuthValidator.validate(
            email: auth.session?.user.email ?? "",
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
