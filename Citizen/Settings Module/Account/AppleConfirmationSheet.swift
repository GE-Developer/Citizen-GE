//
//  AppleConfirmationSheet.swift
//  Citizen
//
//  Created by GE-Developer
//

import AuthenticationServices
import SwiftUI

struct AppleConfirmationSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let message: String
    let appleTitle: String
    let cancelTitle: String
    let onNonce: () -> String
    let onToken: (String) -> Void
    let onFailure: () -> Void
    
    var body: some View {
        content
            .background(Color.citizen.background.ignoresSafeArea())
    }
}

// MARK: - Builder
extension AppleConfirmationSheet {
    private var content: some View {
        VStack(spacing: 20) {
            Spacer()
            header
            Spacer()
            appleButton
            cancelButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
            
            Text(message)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
        }
        .multilineTextAlignment(.center)
    }
    
    private var appleButton: some View {
        AppleAuthButton(
            title: appleTitle,
            scopes: [.email],
            onNonce: onNonce,
            onCompletion: handleCompletion
        )
    }
    
    private var cancelButton: some View {
        Button(cancelTitle) { dismiss() }
            .font(.body)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
    }
}

// MARK: - Logic
extension AppleConfirmationSheet {
    private func handleCompletion(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = AppleSignIn.credential(from: authorization) else {
                onFailure()
                return
            }
            onToken(credential.idToken)
        case .failure(let error):
            guard (error as? ASAuthorizationError)?.code != .canceled else {
                dismiss()
                return
            }
            onFailure()
        }
    }
}
