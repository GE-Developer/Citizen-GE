//
//  AppleAuthButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import AuthenticationServices
import SwiftUI

@MainActor
private final class AppleAuthSession: NSObject {
    private var controller: ASAuthorizationController?
    
    private let onCompletion: (Result<ASAuthorization, any Error>) -> Void
    
    init(onCompletion: @escaping (Result<ASAuthorization, any Error>) -> Void) {
        self.onCompletion = onCompletion
        super.init()
    }
    
    func start(scopes: [ASAuthorization.Scope], nonce: String) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = scopes
        request.nonce = nonce
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.controller = controller
        controller.performRequests()
    }
}

// MARK: - Session Callbacks
extension AppleAuthSession: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        onCompletion(.success(authorization))
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        onCompletion(.failure(error))
    }
}

extension AppleAuthSession: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        DeviceLayout.keyWindow ?? ASPresentationAnchor()
    }
}

// MARK: - AppleAuthButton
struct AppleAuthButton: View {
    @Environment(\.isEnabled) private var isEnabled
    
    @State private var session: AppleAuthSession?
    
    private var titleSize: CGFloat { height * 0.4 }
    private var logoSize: CGFloat { height * 0.296 }
    private var logoSpacing: CGFloat { height * 0.158 }
    private var horizontalMargin: CGFloat { height * 0.15 }
    
    private let title: String
    private let scopes: [ASAuthorization.Scope]
    private let onNonce: () -> String
    private let onCompletion: (Result<ASAuthorization, any Error>) -> Void
    
    private let height: CGFloat = 54
    private let cornerRadius: CGFloat = 16
    
    init(
        title: String,
        scopes: [ASAuthorization.Scope],
        onNonce: @escaping () -> String,
        onCompletion: @escaping (Result<ASAuthorization, any Error>) -> Void
    ) {
        self.title = title
        self.scopes = scopes
        self.onNonce = onNonce
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        Button(action: start) { face }
    }
}

// MARK: - Builder
extension AppleAuthButton {
    private var face: some View {
        HStack(spacing: logoSpacing) {
            Image.system.apple
                .font(.system(size: logoSize, weight: .medium))
                .accessibilityHidden(true)
            
            Text(title)
                .font(.system(size: titleSize, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(Color.citizen.whiteAndBlack)
        .padding(.horizontal, horizontalMargin)
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.citizen.blackAndWhite)
        }
        .opacity(isEnabled ? 1 : 0.6)
    }
}

// MARK: - Logic
extension AppleAuthButton {
    private func start() {
        let session = AppleAuthSession(onCompletion: onCompletion)
        self.session = session
        session.start(scopes: scopes, nonce: onNonce())
    }
}
