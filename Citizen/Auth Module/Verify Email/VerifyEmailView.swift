//
//  VerifyEmailView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct VerifyEmailView: View {
    @Binding private var route: AuthRoute
    
    @State private var vm: VerifyEmailViewModel
    
    @FocusState private var codeFocused: Bool
    
    private let origin: AuthMode
    
    init(email: String, name: String?, origin: AuthMode, route: Binding<AuthRoute>) {
        self._route = route
        self.origin = origin
        self._vm = State(initialValue: VerifyEmailViewModel(email: email, name: name))
    }
    
    var body: some View {
        verifyEmailView
            .task {
                vm.start()
                codeFocused = true
            }
            .onChange(of: vm.code) {
                if vm.isCodeComplete {
                    codeFocused = false
                }
            }
    }
}

// MARK: - Builder
extension VerifyEmailView {
    private var verifyEmailView: some View {
        AuthScreen {
            AuthBackButton(isDisabled: vm.isLoading, action: backPressed)
                .frame(maxWidth: .infinity, alignment: .leading)
        } content: {
            VStack(spacing: 20) {
                emailBadge
                title
                subtitle
                codeBoxes
                resendRow
            }
        } bottomBar: {
            AuthActionButton(
                title: vm.verifyTitle,
                isLoading: vm.isLoading,
                isDisabled: vm.isVerifyDisabled,
                action: verifyPressed
            )
        }
    }
    
    private var emailBadge: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Gradient.accent)
            .frame(width: 72, height: 72)
            .overlay {
                Image.system.envelope
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.citizen.white)
            }
            .shadow(color: Color.citizen.accent.opacity(0.5), radius: 16)
    }
    
    private var title: some View {
        Text(vm.title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .multilineTextAlignment(.center)
    }
    
    private var subtitle: some View {
        VStack(spacing: 2) {
            Text(vm.subtitle)
                .foregroundStyle(Color.citizen.secondaryText)
            Text(vm.email)
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.mainText)
        }
        .font(.subheadline)
        .fontDesign(.rounded)
        .multilineTextAlignment(.center)
    }
    
    private var codeBoxes: some View {
        AuthCodeBoxes(
            code: $vm.code,
            length: vm.codeLength,
            isFocused: $codeFocused,
            isDisabled: vm.isLoading
        )
    }
    
    private var resendRow: some View {
        Group {
            if vm.showsResendButton {
                Button(action: resendPressed) {
                    Text(vm.resendTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.citizen.accent)
                }
                .disabled(!vm.canResend)
                .opacity(vm.canResend ? 1 : 0.5)
            } else {
                Text(vm.resendCountdownText)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
        }
        .font(.footnote)
        .fontDesign(.rounded)
    }
}

// MARK: - Logic
extension VerifyEmailView {
    private func verifyPressed() {
        Task { await vm.verify() }
    }
    
    private func resendPressed() {
        Task { await vm.resend() }
    }
    
    private func backPressed() {
        route = origin == .signIn ? .signIn : .signUp
    }
}
