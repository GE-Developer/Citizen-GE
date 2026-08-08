//
//  AccountViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreGraphics
import Foundation

@MainActor
@Observable
final class AccountViewModel {
    enum DangerousAction {
        case clearProgress
        case deleteAccount
    }
    
    var showNicknameAlert = false
    var editedNickname = ""
    var showDeleteError = false
    var showDangerAlert = false
    var showAppleConfirmation = false
    var confirmationPassword = ""
    
    var avatar: CGImage? {
        avatarStore.avatar
    }
    
    var hasAvatar: Bool {
        avatarStore.avatar != nil
    }
    
    var email: String {
        AuthManager.shared.session?.user.email ?? ""
    }
    
    var nickname: String {
        profileSync.nickname
    }
    
    var mood: String {
        profileSync.mood
    }
    
    var userId: String {
        AuthManager.shared.session?.user.id.uuidString.lowercased() ?? ""
    }
    
    var nicknameRowTitle: String {
        nickname.isEmpty ? nicknameTitle : nickname
    }
    
    var canSaveNickname: Bool {
        let trimmed = editedNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed != nickname
    }
    
    var dangerTitle: String {
        switch pendingAction {
        case .clearProgress: return clearProgressTitle
        case .deleteAccount: return deleteAccountAlertTitle
        case .none: return ""
        }
    }
    
    var dangerConfirmTitle: String {
        switch pendingAction {
        case .clearProgress: return clearProgressConfirmTitle
        case .deleteAccount: return deleteAccountConfirmTitle
        case .none: return ""
        }
    }
    
    var requiresAppleConfirmation: Bool {
        let auth = AuthManager.shared
        return !auth.canConfirmWithPassword && auth.canConfirmWithApple
    }
    
    var canChangePassword: Bool {
        AuthManager.shared.canConfirmWithPassword
    }
    
    var dangerMessage: String {
        let prompt = requiresAppleConfirmation ? applePromptMessage : passwordPromptMessage
        
        switch pendingAction {
        case .clearProgress:
            return [clearProgressAlertMessage, clearProgressScoreNotice, prompt]
                .joined(separator: "\n\n")
        case .deleteAccount:
            return [deleteAccountAlertMessage, prompt]
                .joined(separator: "\n\n")
        case .none:
            return ""
        }
    }
    
    var canConfirmDangerousAction: Bool {
        guard !isProcessing else { return false }
        return requiresAppleConfirmation || !confirmationPassword.isEmpty
    }
    
    var reviewURL: URL? {
        URL(string: "https://apps.apple.com/app/\(Plist.get(.appID))?action=write-review")
    }
    
    private(set) var isProcessing = false
    private(set) var pendingAction: DangerousAction?
    
    private var moodTask: Task<Void, Never>?
    private var appleNonce: String?
    
    let moods = Mood.allCases
    
    let title = L10n("Settings.Account.title")
    let profileTitle = L10n("Settings.Account.Profile.title")
    let emailTitle = L10n("Auth.Email.placeholder")
    let avatarChangeTitle = L10n("Settings.Account.Avatar.change")
    let avatarRemoveTitle = L10n("Settings.Account.Avatar.remove")
    let nicknameTitle = L10n("Settings.Account.Nickname.title")
    let moodTitle = L10n("Settings.Account.Mood.title")
    let userIdTitle = L10n("Settings.Account.Id.title")
    let changePasswordTitle = L10n("Settings.Account.ChangePassword.title")
    let passwordPlaceholder = L10n("Auth.Password.placeholder")
    let saveTitle = L10n("Saved.renameConfirm")
    let signOutTitle = L10n("Settings.Account.SignOut.title")
    let deleteAccountTitle = L10n("Settings.Account.DeleteAccount.title")
    let deleteAccountAlertTitle = L10n("Settings.Account.DeleteAccount.alertTitle")
    let deleteAccountConfirmTitle = L10n("Settings.Account.DeleteAccount.alertConfirm")
    let deleteAccountErrorMessage = L10n("Settings.Account.DeleteAccount.error")
    let accessTitle = L10n("Settings.Access.title")
    let subscriptionTitle = L10n("Settings.Access.Subscription.title")
    let reviewTitle = L10n("Settings.Access.Review.title")
    let dataTitle = L10n("Settings.Data.title")
    let clearProgressTitle = L10n("Settings.Data.ClearProgress.title")
    let clearProgressConfirmTitle = L10n("Settings.Data.ClearProgress.alertConfirm")
    let deleteDataTitle = L10n("Settings.Data.DeleteData.title")
    let deleteDataAlertMessage = L10n("Settings.Data.DeleteData.alertMessage")
    let deleteDataConfirmTitle = L10n("Settings.Data.DeleteData.alertConfirm")
    let cancelTitle = L10n("SearchField.cancel")
    let appleConfirmTitle = L10n("Settings.Account.Confirm.appleTitle")
    let appleButtonTitle = L10n("Auth.appleButton")
    
    private let nicknameMaxLength = 30
    private let avatarLoadFailedMessage = L10n("Settings.Account.Avatar.loadFailed")
    private let avatarUploadFailedMessage = L10n("Settings.Account.Avatar.uploadFailed")
    private let idCopiedMessage = L10n("Settings.Account.Id.copied")
    private let savedMessage = L10n("Settings.Account.Feedback.saved")
    private let savedOfflineMessage = L10n("Settings.Account.Feedback.savedOffline")
    private let saveFailedMessage = L10n("Settings.Account.Feedback.failed")
    private let deleteAccountAlertMessage = L10n("Settings.Account.DeleteAccount.alertMessage")
    private let clearProgressAlertMessage = L10n("Settings.Data.ClearProgress.alertMessage")
    private let clearProgressScoreNotice = L10n("Settings.Data.ClearProgress.scoreNotice")
    private let progressClearedMessage = L10n("Settings.Data.ClearProgress.done")
    private let passwordPromptMessage = L10n("Settings.Account.Confirm.passwordPrompt")
    private let wrongPasswordMessage = L10n("Settings.Account.Confirm.wrongPassword")
    private let applePromptMessage = L10n("Settings.Account.Confirm.applePrompt")
    private let appleMismatchMessage = L10n("Settings.Account.Confirm.appleMismatch")
    
    private let avatarStore = AvatarStore.shared
    private let profileSync = ProfileSync.shared
    private let feedback = FeedbackManager.shared
    private let haptics = HapticsManager.shared
    
    func saveAvatar(_ data: Data) {
        Task {
            guard let jpeg = await avatarStore.save(data) else {
                haptics.impact()
                feedback.show(avatarLoadFailedMessage, style: .error)
                return
            }
            
            present(await profileSync.uploadAvatar(jpeg: jpeg), failure: avatarUploadFailedMessage)
        }
    }
    
    func removeAvatar() {
        Task { present(await profileSync.removeAvatar()) }
    }
    
    func changeNickname() {
        editedNickname = nickname
        showNicknameAlert = true
    }
    
    func confirmNicknameChange() {
        let name = String(
            editedNickname
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(nicknameMaxLength)
        )
        
        guard !name.isEmpty, name != nickname else { return }
        profileSync.setNickname(name)
        
        Task {
            present(await profileSync.commitIdentityEdit(.nickname))
        }
    }
    
    func selectMood(_ mood: Mood) {
        haptics.selectionChanged()
        profileSync.setMood(self.mood == mood.rawValue ? "" : mood.rawValue)
        
        moodTask?.cancel()
        moodTask = Task { [weak self] in
            guard let self else { return }
            
            let outcome = await profileSync.commitIdentityEdit(.mood)
            
            guard !Task.isCancelled else { return }
            present(outcome)
        }
    }
    
    func isMoodSelected(_ mood: Mood) -> Bool {
        self.mood == mood.rawValue
    }
    
    func userIdCopied() {
        haptics.notification(type: .success)
        feedback.show(idCopiedMessage, style: .success)
    }
    
    func askConfirmation(for action: DangerousAction) {
        pendingAction = action
        confirmationPassword = ""
        showDangerAlert = true
    }
    
    func confirmDangerousAction() {
        guard let action = pendingAction, !isProcessing else { return }
        
        guard !requiresAppleConfirmation else {
            showAppleConfirmation = true
            return
        }
        
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            guard await passwordConfirmed() else { return }
            await perform(action)
        }
    }
    
    func startAppleConfirmation() -> String {
        let nonce = AppleSignIn.makeNonce()
        appleNonce = nonce.raw
        return nonce.hashed
    }
    
    func completeAppleConfirmation(idToken: String) {
        guard let action = pendingAction, !isProcessing, let nonce = appleNonce else { return }
        appleNonce = nil
        showAppleConfirmation = false
        
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            guard await appleConfirmed(idToken: idToken, nonce: nonce) else { return }
            await perform(action)
        }
    }
    
    func appleConfirmationFailed() {
        appleNonce = nil
        haptics.notification(type: .error)
        feedback.show(saveFailedMessage, style: .error)
    }
    
    func signOut() {
        Task {
            await AuthManager.shared.signOut()
        }
    }
    
    func deleteDownloadedData() {
        guard !isProcessing else { return }
        
        Task {
            isProcessing = true
            
            defer { isProcessing = false }
            
            ResourceDownloader.shared.wipeAllContent()
            MediaStore.shared.wipeAllMedia()
            LeaderboardStore.shared.wipe()
            ContactsStore.shared.wipe()
            RemoteImageStore.shared.wipeAll()
            
            await AuthManager.shared.signOut()
        }
    }
    
    private func passwordConfirmed() async -> Bool {
        let password = confirmationPassword
        confirmationPassword = ""
        
        do {
            try await AuthManager.shared.verifyPassword(password)
            return true
        } catch {
            haptics.notification(type: .error)
            
            if case .invalidCredentials = error {
                feedback.show(wrongPasswordMessage, style: .error)
            } else {
                feedback.show(error.message, style: .error)
            }
            
            return false
        }
    }
    
    private func appleConfirmed(idToken: String, nonce: String) async -> Bool {
        do {
            try await AuthManager
                .shared
                .verifyAppleCredential(idToken: idToken, nonce: nonce)
            return true
        } catch {
            haptics.notification(type: .error)
            
            if case .invalidCredentials = error {
                feedback.show(appleMismatchMessage, style: .error)
            } else {
                feedback.show(error.message, style: .error)
            }
            
            return false
        }
    }
    
    private func perform(_ action: DangerousAction) async {
        switch action {
        case .clearProgress: clearProgress()
        case .deleteAccount: await deleteAccount()
        }
    }
    
    private func clearProgress() {
        ProgressSync.shared.clearProgress()
        haptics.notification(type: .success)
        feedback.show(progressClearedMessage, style: .success)
    }
    
    private func deleteAccount() async {
        do {
            try await AuthManager.shared.deleteAccount()
        } catch {
            showDeleteError = true
        }
    }
    
    private func present(_ outcome: SaveOutcome, failure: String? = nil) {
        switch outcome {
        case .saved:
            haptics.notification(type: .success)
            feedback.show(savedMessage, style: .success)
        case .offline:
            haptics.notification(type: .warning)
            feedback.show(savedOfflineMessage, style: .info)
        case .failed:
            haptics.notification(type: .error)
            feedback.show(failure ?? saveFailedMessage, style: .error)
        }
    }
}
