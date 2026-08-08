//
//  SignUpView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SignUpView: View {
    @Binding private var route: AuthRoute
    
    @State private var vm = SignUpViewModel()
    
    init(route: Binding<AuthRoute>) {
        self._route = route
    }
    
    var body: some View {
        signUpView
    }
}

// MARK: - Builder
extension SignUpView {
    private var signUpView: some View {
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
                FormHeaderView(vm.nameLabel)
                AuthTextField(
                    text: $vm.name,
                    placeholder: vm.nameLabel,
                    icon: .system.person,
                    contentType: .name
                )
            }
            .padding(.bottom, 8)
            
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
                CustomSecureField(
                    password: $vm.password,
                    placeholder: vm.createPasswordPlaceholder,
                    isNewPassword: true
                )
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.repeatPasswordLabel)
                CustomSecureField(
                    password: $vm.confirmPassword,
                    placeholder: vm.repeatPasswordLabel,
                    isNewPassword: true
                )
            }
        }
        .disabled(vm.isLoading)
    }
}

// MARK: - Logic
extension SignUpView {
    private func submitPressed() {
        Task {
            guard let pending = await vm.submit() else { return }
            route = .verifyEmail(
                email: pending.email,
                name: pending.name,
                origin: .signUp
            )
        }
    }
    
    private func backPressed() {
        route = .welcome
    }
}
