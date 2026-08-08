//
//  AuthFieldError.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AuthFieldError {
    case emptyName
    case emptyEmail
    case invalidEmail
    case shortPassword
    case passwordMismatch
    
    @MainActor
    var message: String {
        switch self {
        case .emptyName:
            return L10n("AuthField.emptyName")
        case .emptyEmail:
            return L10n("AuthField.emptyEmail")
        case .invalidEmail:
            return L10n("AuthField.invalidEmail")
        case .shortPassword:
            return L10n("AuthField.shortPassword")
        case .passwordMismatch:
            return L10n("AuthField.passwordMismatch")
        }
    }
}
