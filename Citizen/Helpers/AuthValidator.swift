//
//  AuthValidator.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AuthValidator {
    
    struct Result {
        let emailError: AuthFieldError?
        let passwordError: AuthFieldError?
        let confirmError: AuthFieldError?
        
        var isValid: Bool {
            emailError == nil
            && passwordError == nil
            && confirmError == nil
        }
    }
    
    static let minPasswordLength = 8
    
    static func normalizeEmail(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        email.wholeMatch(of: /[^@\s]+@[^@\s.]+(\.[^@\s.]+)+/) != nil
    }
    
    static func sanitizeCode(_ raw: String, length: Int) -> String {
        String(
            raw
                .filter(\.isNumber)
                .prefix(length)
        )
    }
    
    static func validate(
        email rawEmail: String,
        password: String,
        confirmPassword: String?
    ) -> Result {
        let email = normalizeEmail(rawEmail)
        let emailError: AuthFieldError?
        let passwordError: AuthFieldError?
        
        var confirmError: AuthFieldError?
        
        if email.isEmpty {
            emailError = .emptyEmail
        } else if isValidEmail(email) {
            emailError = nil
        } else {
            emailError = .invalidEmail
        }
        
        if password.count < minPasswordLength {
            passwordError = .shortPassword
        } else {
            passwordError = nil
        }
        
        if let confirmPassword, passwordError == nil, confirmPassword != password {
            confirmError = .passwordMismatch
        }
        
        return Result(
            emailError: emailError,
            passwordError: passwordError,
            confirmError: confirmError
        )
    }
}
