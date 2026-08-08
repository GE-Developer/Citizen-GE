//
//  SignInView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SignInView: View {
    @Binding private var route: AuthRoute
    
    @State private var vm = SignInViewModel()
    
    init(route: Binding<AuthRoute>) {
        self._route = route
    }
    
    var body: some View {
        signInView
    }
}

// MARK: - Builder
extension SignInView {
    private var signInView: some View {
        AuthScreen {
            AuthBackButton(isDisabled: vm.isLoading, action: backPressed)
                .frame(maxWidth: .infinity, alignment: .leading)
        } content: {
            VStack(spacing: 20) {
                title
                subtitle
                fields
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
    
    private var title: some View {
        Text(vm.title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
    }
    
    private var subtitle: some View {
        Text(vm.subtitle)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .multilineTextAlignment(.center)
    }
    
    private var fields: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.emailLabel)
                AuthTextField(
                    text: $vm.email,
                    placeholder: vm.emailPlaceholder,
                    icon: .system.envelope,
                    keyboard: .emailAddress,
                    contentType: .username
                )
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.passwordLabel)
                CustomSecureField(password: $vm.password, placeholder: vm.passwordLabel)
            }
            
            Button(action: forgotPasswordPressed) {
                Text(vm.forgotPasswordTitle)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 4)
        }
        .disabled(vm.isLoading)
    }
}

// MARK: - Logic
extension SignInView {
    private func submitPressed() {
        Task {
            guard let pendingEmail = await vm.submit() else { return }
            route = .verifyEmail(email: pendingEmail, name: nil, origin: .signIn)
        }
    }
    
    private func forgotPasswordPressed() {
        Task {
            guard let email = await vm.forgotPassword() else { return }
            route = .resetPassword(email: email)
        }
    }
    
    private func backPressed() {
        route = .welcome
    }
}
