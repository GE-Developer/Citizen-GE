//
//  AccountView.swift
//  Citizen
//
//  Created by GE-Developer
//

import PhotosUI
import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var store: StoreManager
    
    @Environment(\.openURL) private var openURL
    
    @State private var vm = AccountViewModel()
    @State private var showChangePassword = false
    @State private var showPhotoPicker = false
    @State private var showAvatarOptions = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showSignOutConfirmation = false
    @State private var showDeleteDataConfirmation = false
    @State private var showPayWall = false
    
    private let moodColumns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible())]
    
    var body: some View {
        accountView
            .navigationDestination(isPresented: $showChangePassword) {
                NavigationLazyView(ChangePasswordView())
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhoto,
                matching: .images
            )
            .onChange(of: selectedPhoto) { applySelectedPhoto() }
            .confirmationDialog(
                "",
                isPresented: $showAvatarOptions,
                titleVisibility: .hidden
            ) {
                Button(vm.avatarChangeTitle) { showPhotoPicker = true }
                Button(vm.avatarRemoveTitle, role: .destructive) { vm.removeAvatar() }
                Button(vm.cancelTitle, role: .cancel) {}
            }
            .alert(vm.nicknameTitle, isPresented: $vm.showNicknameAlert) {
                TextField(vm.nicknameTitle, text: $vm.editedNickname)
                Button(vm.cancelTitle, role: .cancel) {}
                Button(vm.saveTitle, action: vm.confirmNicknameChange)
                    .disabled(!vm.canSaveNickname)
            }
            .alert(vm.signOutTitle, isPresented: $showSignOutConfirmation) {
                Button(vm.signOutTitle, role: .destructive) { vm.signOut() }
                Button(vm.cancelTitle, role: .cancel) {}
            }
            .alert(vm.deleteDataTitle, isPresented: $showDeleteDataConfirmation) {
                Button(vm.deleteDataConfirmTitle, role: .destructive) {
                    vm.deleteDownloadedData()
                }
                Button(vm.cancelTitle, role: .cancel) {}
            } message: {
                Text(vm.deleteDataAlertMessage)
            }
            .alert(vm.dangerTitle, isPresented: $vm.showDangerAlert) {
                if !vm.requiresAppleConfirmation {
                    SecureField(vm.passwordPlaceholder, text: $vm.confirmationPassword)
                }
                Button(
                    vm.dangerConfirmTitle,
                    role: .destructive,
                    action: vm.confirmDangerousAction
                )
                .disabled(!vm.canConfirmDangerousAction)
                Button(vm.cancelTitle, role: .cancel) {}
            } message: {
                Text(vm.dangerMessage)
            }
            .sheet(isPresented: $vm.showAppleConfirmation) {
                AppleConfirmationSheet(
                    title: vm.appleConfirmTitle,
                    message: vm.dangerMessage,
                    appleTitle: vm.appleButtonTitle,
                    cancelTitle: vm.cancelTitle,
                    onNonce: vm.startAppleConfirmation,
                    onToken: vm.completeAppleConfirmation,
                    onFailure: vm.appleConfirmationFailed
                )
            }
            .alert(vm.deleteAccountErrorMessage, isPresented: $vm.showDeleteError) {}
    }
}

// MARK: - Builder
extension AccountView {
    private var accountView: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 25) {
                avatarSection
                profileForm
                moodSection
                accessForm
                dataForm
                userIdRow
                deleteAccountButton
            }
        }
    }
    
    private var avatarSection: some View {
        Button(action: avatarTapped) {
            ZStack(alignment: .bottomTrailing) {
                avatarCircle
                cameraBadge
                    .padding(.trailing, 5)
                    .padding(.bottom, 5)
            }
        }
    }
    
    private var avatarCircle: some View {
        ZStack {
            if let avatar = vm.avatar {
                Image.avatar(avatar)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Gradient.accent.opacity(0.15))
                Image.system.person
                    .font(.system(size: 46, weight: .medium))
                    .foregroundStyle(Gradient.accent)
            }
        }
        .frame(width: 150, height: 150)
        .clipShape(Circle())
        .padding(10)
        .overlay {
            Circle()
                .strokeBorder(Gradient.accent, lineWidth: 5)
        }
    }
    
    private var cameraBadge: some View {
        ZStack {
            Circle()
                .fill(Gradient.accent)
            Image.system.camera
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.white)
        }
        .frame(width: 34, height: 34)
        .padding(5)
        .overlay {
            Circle()
                .strokeBorder(Color.citizen.background, lineWidth: 5)
        }
    }
    
    private var profileForm: some View {
        CustomForm(headerText: vm.profileTitle) {
            nicknameButton
            Divider()
                .padding(.leading, 50)
            emailRow
            Divider()
                .padding(.leading, 50)
            if vm.canChangePassword {
                changePasswordButton
                Divider()
                    .padding(.leading, 50)
            }
            signOutButton
        }
        .disabled(vm.isProcessing)
    }
    
    private var moodSection: some View {
        CustomForm(headerText: vm.moodTitle) {
            LazyVGrid(columns: moodColumns, spacing: 10) {
                ForEach(vm.moods, id: \.self) { mood in
                    moodButton(mood)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }
    
    private var nicknameButton: some View {
        CustomButtonRow(
            icon: .system.person,
            title: vm.nicknameTitle,
            additionalTitle: vm.nicknameRowTitle,
            isLink: true,
            action: { vm.changeNickname() }
        )
    }
    
    private var emailRow: some View {
        CustomButtonRow(
            icon: .system.envelope,
            title: vm.emailTitle,
            additionalTitle: vm.email,
            action: { }
        )
    }
    
    private var changePasswordButton: some View {
        CustomButtonRow(
            icon: .system.key(),
            title: vm.changePasswordTitle,
            isLink: true,
            action: { showChangePassword = true }
        )
    }
    
    private var signOutButton: some View {
        CustomButtonRow(
            icon: .system.signOut,
            title: vm.signOutTitle,
            isCritical: true,
            action: { showSignOutConfirmation = true }
        )
    }
    
    private var accessForm: some View {
        CustomForm(headerText: vm.accessTitle) {
            PremiumView(.status)
        } content: {
            subscriptionButton
            Divider()
                .padding(.leading, 50)
            reviewButton
        }
    }
    
    private var subscriptionButton: some View {
        CustomButtonRow(
            icon: .system.subscription,
            title: vm.subscriptionTitle,
            isLink: true,
            action: { showPayWall = true }
        )
    }
    
    private var reviewButton: some View {
        CustomButtonRow(
            icon: .system.reviewLike,
            title: vm.reviewTitle,
            action: openReview
        )
    }
    
    private var dataForm: some View {
        CustomForm(headerText: vm.dataTitle) {
            CustomButtonRow(
                icon: .system.eraser,
                title: vm.clearProgressTitle,
                action: { vm.askConfirmation(for: .clearProgress) }
            )
            Divider()
                .padding(.leading, 50)
            CustomButtonRow(
                icon: .system.deleteData,
                title: vm.deleteDataTitle,
                action: { showDeleteDataConfirmation = true }
            )
        }
        .disabled(vm.isProcessing)
    }
    
    private var deleteAccountButton: some View {
        Button(action: { vm.askConfirmation(for: .deleteAccount) }) {
            HStack(spacing: 8) {
                Image.system.trash
                Text(vm.deleteAccountTitle)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.redDark)
            .frame(maxWidth: .infinity)
        }
        .disabled(vm.isProcessing)
    }
    
    private var userIdRow: some View {
        Button(action: copyUserId) {
            HStack(spacing: 10) {
                Image.system.copy
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.userIdTitle)
                    Text(vm.userId)
                        .monospaced()
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Spacer()
            }
            .font(.caption2)
            .foregroundStyle(Color.citizen.secondaryText)
            .fontDesign(.rounded)
        }
    }
    
    private func moodButton(_ mood: Mood) -> some View {
        Button {
            vm.selectMood(mood)
        } label: {
            MoodChipView(
                mood,
                isSelected: vm.isMoodSelected(mood),
                isExpanded: true
            )
        }
    }
}

// MARK: - Logic
extension AccountView {
    private func openReview() {
        guard let url = vm.reviewURL else { return }
        openURL(url)
    }
    
    private func copyUserId() {
        UIPasteboard.general.string = vm.userId
        vm.userIdCopied()
    }
    
    private func avatarTapped() {
        if vm.hasAvatar {
            showAvatarOptions = true
        } else {
            showPhotoPicker = true
        }
    }
    
    private func applySelectedPhoto() {
        guard let item = selectedPhoto else { return }
        
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                return
            }
            vm.saveAvatar(data)
        }
    }
}
