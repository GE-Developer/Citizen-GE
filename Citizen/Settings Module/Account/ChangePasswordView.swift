//
//  ChangePasswordView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var vm = ChangePasswordViewModel()
    
    var body: some View {
        changePasswordView
            .onChange(of: vm.didChangePassword, dismissAfterSuccess)
    }
}

// MARK: - Builder
extension ChangePasswordView {
    private var changePasswordView: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 28) {
                fields
                submitButton
            }
        }
    }
    
    private var fields: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.currentPasswordLabel)
                CustomSecureField(
                    password: $vm.currentPassword,
                    placeholder: vm.currentPasswordLabel
                )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                FormHeaderView(vm.newPasswordLabel)
                CustomSecureField(
                    password: $vm.newPassword,
                    placeholder: vm.newPasswordLabel,
                    isNewPassword: true
                )
            }
            
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
    
    private var submitButton: some View {
        AuthActionButton(
            title: vm.submitTitle,
            isLoading: vm.isLoading,
            isDisabled: vm.isSubmitDisabled,
            action: submitPressed
        )
    }
}

// MARK: - Logic
extension ChangePasswordView {
    private func submitPressed() {
        Task { await vm.submit() }
    }
    
    private func dismissAfterSuccess() {
        guard vm.didChangePassword else { return }
        dismiss()
    }
}
