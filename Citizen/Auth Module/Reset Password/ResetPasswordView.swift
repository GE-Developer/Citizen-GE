//
//  ResetPasswordView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ResetPasswordView: View {
    @Binding private var route: AuthRoute
    
    @State private var vm: ResetPasswordViewModel
    
    @FocusState private var codeFocused: Bool
    
    init(email: String, route: Binding<AuthRoute>) {
        self._route = route
        self._vm = State(initialValue: ResetPasswordViewModel(email: email))
    }
    
    var body: some View {
        resetPasswordView
            .task { vm.start() }
            .onChange(of: vm.code) {
                if vm.isCodeComplete {
                    codeFocused = false
                }
            }
    }
}

// MARK: - Builder
extension ResetPasswordView {
    private var resetPasswordView: some View {
        AuthScreen {
            AuthBackButton(isDisabled: vm.isLoading, action: backPressed)
                .frame(maxWidth: .infinity, alignment: .leading)
        } content: {
            VStack(spacing: 20) {
                badge
                title
                subtitle
                fields
                resendRow
            }
        } bottomBar: {
            AuthActionButton(
                title: vm.submitTitle,
                isLoading: vm.isLoading,
                isDisabled: vm.isSubmitDisabled,
                action: submitPressed
            )
        }
    }
    
    private var badge: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Gradient.accent)
            .frame(width: 72, height: 72)
            .overlay {
                Image.system.lock
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
    
    private var fields: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.codeLabel)
                AuthCodeBoxes(
                    code: $vm.code,
                    length: vm.codeLength,
                    isFocused: $codeFocused,
                    isDisabled: vm.isLoading
                )
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.newPasswordLabel)
                CustomSecureField(
                    password: $vm.newPassword,
                    placeholder: vm.newPasswordLabel,
                    isNewPassword: true
                )
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.confirmPasswordLabel)
                CustomSecureField(
                    password: $vm.confirmPassword,
                    placeholder: vm.confirmPasswordLabel,
                    isNewPassword: true
                )
            }
        }
        .disabled(vm.isLoading)
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
extension ResetPasswordView {
    private func submitPressed() {
        Task { await vm.submit() }
    }
    
    private func resendPressed() {
        Task { await vm.resend() }
    }
    
    private func backPressed() {
        route = .signIn
    }
}
