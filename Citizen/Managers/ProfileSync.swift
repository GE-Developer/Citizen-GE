//
//  ProfileSync.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum SaveOutcome {
    case saved
    case offline
    case failed
}

@MainActor
@Observable
final class ProfileSync {
    enum IdentityField: String, CaseIterable {
        case nickname
        case mood
        case avatarURL
        case language
    }
    
    private(set) var nickname: String
    private(set) var mood: String
    
    static let shared = ProfileSync()
    
    private var pushTask: Task<Void, Never>?
    private var avatarTask: Task<Void, Never>?
    
    private let service = ProfileService.shared
    private let avatarService = AvatarService.shared
    private let avatarStore = AvatarStore.shared
    private let networkMonitor = NetworkMonitor.shared
    private let authManager = AuthManager.shared
    private let languageManager = LanguageManager.shared
    private let userDefaults = UserDefaults.standard
    private let fetchTimeout: TimeInterval = 2
    
    private init() {
        nickname = UserDefaults.standard.string(forKey: AppStorageKey.userNickname.key) ?? ""
        mood = UserDefaults.standard.string(forKey: AppStorageKey.userMood.key) ?? ""
    }
    
    func configure() {
        networkMonitor.onRestore { [weak self] in
            guard let self, authManager.userID != nil, !dirtyFields.isEmpty else { return }
            push()
        }
    }
    
    func setNickname(_ value: String) {
        userDefaults.set(value, forKey: AppStorageKey.userNickname.key)
        nickname = value
    }
    
    func setMood(_ value: String) {
        userDefaults.set(value, forKey: AppStorageKey.userMood.key)
        mood = value
    }
    
    func registerLocalIdentity(nickname: String?) {
        if let nickname {
            setNickname(nickname)
            markDirty(.nickname)
        }
        setLocalEditedAt(Date())
    }
    
    func noteLocalEdit() {
        markDirty(.language)
        
        guard authManager.userID != nil else { return }
        setLocalEditedAt(Date())
        push()
    }
    
    func commitIdentityEdit(_ field: IdentityField) async -> SaveOutcome {
        markDirty(field)
        setLocalEditedAt(Date())
        pushTask?.cancel()
        
        do {
            try await sendIdentity()
            return .saved
        } catch {
            return networkMonitor.isConnected ? .failed : .offline
        }
    }
    
    func handleSignedOut() {
        pushTask?.cancel()
        pushTask = nil
        avatarTask?.cancel()
        avatarTask = nil
        nickname = ""
        mood = ""
        userDefaults.removeObject(forKey: AppStorageKey.identityDirtyFields.key)
        userDefaults.removeObject(forKey: AppStorageKey.userNickname.key)
        userDefaults.removeObject(forKey: AppStorageKey.userMood.key)
        userDefaults.removeObject(forKey: AppStorageKey.userAvatarURL.key)
        userDefaults.removeObject(forKey: AppStorageKey.avatarUploadPending.key)
        userDefaults.removeObject(forKey: AppStorageKey.userDataUpdatedAt.key)
    }
    
    func uploadAvatar(jpeg: Data) async -> SaveOutcome {
        guard let userID = authManager.userID else { return .failed }
        
        do {
            let url = try await avatarService.upload(userID: userID, jpeg: jpeg)
            userDefaults.set(url, forKey: AppStorageKey.userAvatarURL.key)
            userDefaults.removeObject(forKey: AppStorageKey.avatarUploadPending.key)
            
            await avatarService.deleteAll(userID: userID, except: url)
            
            return await commitIdentityEdit(.avatarURL)
        } catch {
            userDefaults.set(true, forKey: AppStorageKey.avatarUploadPending.key)
            
            return networkMonitor.isConnected ? .failed : .offline
        }
    }
    
    func removeAvatar() async -> SaveOutcome {
        guard let userID = authManager.userID else { return .failed }
        await avatarService.deleteAll(userID: userID, except: nil)
        
        avatarStore.wipe()
        userDefaults.set("", forKey: AppStorageKey.userAvatarURL.key)
        userDefaults.removeObject(forKey: AppStorageKey.avatarUploadPending.key)
        
        return await commitIdentityEdit(.avatarURL)
    }
    
    func syncOnLoad() async {
        guard authManager.userID != nil else { return }
        
        await retryPendingAvatarUpload()
        
        let dirtyBeforeFetch = dirtyFields
        let identity: ProfileIdentity?
        
        do {
            identity = try await fetchIdentityBounded()
        } catch {
            return
        }
        
        if identity == nil {
            for field in IdentityField.allCases {
                markDirty(field)
            }
        }
        
        let dirty = dirtyBeforeFetch.union(dirtyFields)
        
        if let identity {
            apply(identity, skipping: dirty)
        }
        
        if !dirtyFields.isEmpty {
            setLocalEditedAt(Date())
            push()
        }
        
        ensureNicknamePresent(serverNickname: identity?.nickname)
    }
    
    private func ensureNicknamePresent(serverNickname: String?) {
        guard nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              serverNickname?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true,
              !dirtyFields.contains(.nickname),
              let generated = defaultNickname(from: authManager.userID)
        else { return }
        
        setNickname(generated)
        markDirty(.nickname)
        setLocalEditedAt(Date())
        push()
    }
    
    private func defaultNickname(from userID: UUID?) -> String? {
        guard let userID else { return nil }
        return "Guest(\(userID.uuidString.prefix(5).lowercased()))"
    }
    
    private func apply(_ identity: ProfileIdentity, skipping dirty: Set<IdentityField>) {
        if !dirty.contains(.language),
           let language = identity.language,
           Language(rawValue: language) != nil,
           language != languageManager.currentLanguageID {
            languageManager.currentLanguageID = language
        }
        
        if !dirty.contains(.nickname), let nickname = identity.nickname {
            setNickname(nickname)
        }
        
        if !dirty.contains(.mood) {
            setMood(identity.mood ?? "")
        }
        
        if !dirty.contains(.avatarURL) {
            applyAvatarURL(identity.avatarURL)
        }
    }
    
    private func applyAvatarURL(_ serverURL: String?) {
        let localURL = UserDefaults.standard.string(forKey: AppStorageKey.userAvatarURL.key)
        
        guard let serverURL, !serverURL.isEmpty else {
            if let localURL, !localURL.isEmpty {
                avatarStore.wipe()
                userDefaults.set("", forKey: AppStorageKey.userAvatarURL.key)
            }
            
            return
        }
        
        guard serverURL != localURL else { return }
        
        let ownerID = authManager.userID
        avatarTask?.cancel()
        
        avatarTask = Task { [weak self, avatarService] in
            guard let data = try? await avatarService.download(from: serverURL) else { return }
            
            guard let self, !Task.isCancelled else { return }
            
            guard authManager.userID == ownerID else { return }
            
            avatarStore.store(data)
            userDefaults.set(serverURL, forKey: AppStorageKey.userAvatarURL.key)
        }
    }
    
    private func retryPendingAvatarUpload() async {
        guard userDefaults.bool(forKey: AppStorageKey.avatarUploadPending.key),
              let jpeg = avatarStore.currentJPEGData() else { return }
        _ = await uploadAvatar(jpeg: jpeg)
    }
    
    private func push() {
        pushTask?.cancel()
        
        pushTask = Task { [weak self] in
            try? await self?.sendIdentity()
        }
    }
    
    private func sendIdentity() async throws {
        guard let userID = authManager.userID else { return }
        
        let dirty = dirtyFields
        guard !dirty.isEmpty else { return }
        
        let mood = dirty.contains(.mood)
        ? (userDefaults.string(forKey: AppStorageKey.userMood.key) ?? "")
        : nil
        
        try await service.pushIdentity(
            userID: userID,
            email: authManager.session?.user.email,
            nickname: dirty.contains(.nickname)
            ? userDefaults.string(forKey: AppStorageKey.userNickname.key)
            : nil,
            avatarURL: dirty.contains(.avatarURL)
            ? userDefaults.string(forKey: AppStorageKey.userAvatarURL.key)
            : nil,
            language: dirty.contains(.language) ? languageManager.currentLanguageID : nil,
            mood: mood,
            editedAt: localEditedAt() ?? Date()
        )
        
        clearDirty(dirty)
    }
    
    private var dirtyFields: Set<IdentityField> {
        let raw = userDefaults.stringArray(forKey: AppStorageKey.identityDirtyFields.key) ?? []
        return Set(raw.compactMap(IdentityField.init(rawValue:)))
    }
    
    private func markDirty(_ field: IdentityField) {
        var fields = dirtyFields
        guard fields.insert(field).inserted else { return }
        userDefaults.set(fields.map(\.rawValue), forKey: AppStorageKey.identityDirtyFields.key)
    }
    
    private func clearDirty(_ fields: Set<IdentityField>) {
        let remaining = dirtyFields.subtracting(fields)
        userDefaults.set(remaining.map(\.rawValue), forKey: AppStorageKey.identityDirtyFields.key)
    }
    
    // MARK: - Plumbing
    private func fetchIdentityBounded() async throws -> ProfileIdentity? {
        guard let userID = authManager.userID else { return nil }
        
        let timeout = fetchTimeout
        let service = service
        
        return try await withThrowingTaskGroup(of: ProfileIdentity?.self) { group in
            group.addTask { try await service.fetchIdentity(userID: userID) }
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw URLError(.timedOut)
            }
            
            guard let identity = try await group.next() else { throw URLError(.unknown) }
            
            group.cancelAll()
            return identity
        }
    }
    
    private func localEditedAt() -> Date? {
        let stamp = userDefaults.double(forKey: AppStorageKey.userDataUpdatedAt.key)
        return stamp > 0 ? Date(timeIntervalSince1970: stamp) : nil
    }
    
    private func setLocalEditedAt(_ date: Date) {
        userDefaults.set(
            date.timeIntervalSince1970,
            forKey: AppStorageKey.userDataUpdatedAt.key
        )
    }
}
