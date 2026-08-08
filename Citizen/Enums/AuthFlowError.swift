//
//  AuthFlowError.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

enum AuthFlowError: Error {
    case invalidCredentials
    case emailAlreadyRegistered
    case emailNotConfirmed
    case invalidCode
    case banned
    case weakPassword
    case rateLimited
    case network
    case unknown
    
    @MainActor
    var message: String {
        switch self {
        case .invalidCredentials:
            return L10n("AuthError.invalidCredentials")
        case .emailAlreadyRegistered:
            return L10n("AuthError.emailAlreadyRegistered")
        case .emailNotConfirmed:
            return L10n("AuthError.emailNotConfirmed")
        case .invalidCode:
            return L10n("AuthError.invalidCode")
        case .banned:
            return L10n("AuthError.banned")
        case .weakPassword:
            return L10n("AuthError.weakPassword")
        case .rateLimited:
            return L10n("AuthError.rateLimited")
        case .network:
            return L10n("AuthError.network")
        case .unknown:
            return L10n("AuthError.unknown")
        }
    }
    
    static func map(_ error: any Error) -> AuthFlowError {
        if let authError = error as? AuthError {
            switch authError.errorCode {
            case .invalidCredentials:
                return .invalidCredentials
            case .userAlreadyExists, .emailExists:
                return .emailAlreadyRegistered
            case .emailNotConfirmed:
                return .emailNotConfirmed
            case .otpExpired:
                return .invalidCode
            case .userBanned:
                return .banned
            case .weakPassword:
                return .weakPassword
            case .overRequestRateLimit:
                return .rateLimited
            default:
                return .unknown
            }
        }
        
        if error is URLError {
            return .network
        }
        
        return .unknown
    }
}
