//
//  AuthRoute.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AuthRoute: Hashable {
    case welcome
    case signIn
    case signUp
    case verifyEmail(email: String, name: String?, origin: AuthMode)
    case resetPassword(email: String)
    
    var depth: Int {
        switch self {
        case .welcome:
            0
        case .signIn, .signUp:
            1
        case .verifyEmail, .resetPassword:
            2
        }
    }
}
