//
//  AppleSignIn.swift
//  Citizen
//
//  Created by GE-Developer
//

import AuthenticationServices
import CryptoKit

enum AppleSignIn {
    static func makeNonce() -> (raw: String, hashed: String) {
        let raw = randomNonceString()
        return (raw, sha256(raw))
    }
    
    static func credential(from authorization: ASAuthorization) -> (idToken: String, fullName: String?)? {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else { return nil }
        
        return (idToken, credential.fullName.flatMap(formattedName))
    }
    
    private static func formattedName(_ components: PersonNameComponents) -> String? {
        let name = PersonNameComponentsFormatter()
            .string(from: components)
            .trimmingCharacters(in: .whitespaces)
        
        return name.isEmpty ? nil : name
    }
    
    private static func sha256(_ input: String) -> String {
        SHA256
            .hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
    
    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._"
        )
        
        var result = ""
        var remaining = length
        
        while remaining > 0 {
            var random: UInt8 = 0
            guard SecRandomCopyBytes(kSecRandomDefault, 1, &random) == errSecSuccess else { continue }
            
            if Int(random) < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        
        return result
    }
}
