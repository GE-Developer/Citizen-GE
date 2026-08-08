//
//  StoreError.swift
//  Citizen
//
//  Created by GE-Developer
//

import StoreKit

enum StoreError: Error {
    case revokedCertificate
    case invalidCertificateChain
    case invalidDeviceVerification
    case invalidEncoding
    case invalidSignature
    case missingRequiredProperties
    case userCancelled
    case pending
    case unknown
    case system
    case productNotChosen
    case loadingError
    case syncError
    
    @MainActor
    var description: String {
        switch self {
        case .revokedCertificate:
            return L10n("StoreError.revokedCertificate")
        case .invalidCertificateChain:
            return L10n("StoreError.invalidCertificateChain")
        case .invalidDeviceVerification:
            return L10n("StoreError.invalidDeviceVerification")
        case .invalidEncoding:
            return L10n("StoreError.invalidEncoding")
        case .invalidSignature:
            return L10n("StoreError.invalidSignature")
        case .missingRequiredProperties:
            return L10n("StoreError.missingRequiredProperties")
        case .userCancelled:
            return L10n("StoreError.userCancelled")
        case .pending:
            return L10n("StoreError.pending")
        case .unknown:
            return L10n("StoreError.unknown")
        case .system:
            return L10n("StoreError.system")
        case .productNotChosen:
            return L10n("StoreError.productNotChosen")
        case .loadingError:
            return L10n("StoreError.loadingError")
        case .syncError:
            return L10n("StoreError.syncError")
        }
    }
    
    static func from(_ reason: VerificationResult<Transaction>.VerificationError) -> StoreError {
        switch reason {
        case .revokedCertificate: return .revokedCertificate
        case .invalidCertificateChain: return .invalidCertificateChain
        case .invalidDeviceVerification: return .invalidDeviceVerification
        case .invalidEncoding: return .invalidEncoding
        case .invalidSignature: return .invalidSignature
        case .missingRequiredProperties: return .missingRequiredProperties
        @unknown default: return .unknown
        }
    }
}
