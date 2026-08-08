//
//  AuthManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase
import RevenueCat

@MainActor
@Observable
final class AuthManager {
    var isAuthenticated: Bool {
        session != nil
    }
    
    var userID: UUID? {
        session?.user.id
    }
    
    var canConfirmWithPassword: Bool {
        hasIdentity(provider: "email")
        || metadataProviders.contains("email")
        || isKnownPasswordUser
    }
    
    var canConfirmWithApple: Bool {
        hasIdentity(provider: "apple")
    }
    
    private(set) var session: Session?
    private(set) var pendingBanNotice = false
    
    private var observationTask: Task<Void, Never>?
    
    static let shared = AuthManager()
    
    private var progressSync: ProgressSync { .shared }
    private var appDataLoader: AppDataLoader { .shared }
    private var profileSync: ProfileSync { .shared }
    private let userDefaults = UserDefaults.standard
    private let client = SupabaseService.client
    private let validationTimeout: TimeInterval = 2
    
    private init() {
        session = client.auth.currentSession
    }
    
    func purgeSessionIfReinstalled() async {
        let markerKey = AppStorageKey.installMarker.key
        
        guard userDefaults.object(forKey: markerKey) == nil else { return }
        userDefaults.set(true, forKey: markerKey)
        
        guard client.auth.currentSession != nil else { return }
        try? await client.auth.signOut(scope: .local)
        session = nil
    }
    
    func startObserving() {
        guard observationTask == nil else { return }
        
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await (event, session) in client.auth.authStateChanges {
                if Task.isCancelled { return }
                handle(event: event, session: session)
            }
        }
    }
    
    func signUp(
        email: String,
        password: String,
        nickname: String?
    ) async throws(AuthFlowError) {
        let response: AuthResponse
        
        do {
            response = try await client.auth.signUp(email: email, password: password)
        } catch {
            throw AuthFlowError.map(error)
        }
        
        if let newSession = response.session {
            session = newSession
            notePasswordAuth()
            profileSync.registerLocalIdentity(nickname: nickname)
            return
        }
        
        let user = response.user
        let identities = user.identities ?? []
        
        if identities.isEmpty || user.createdAt < Date(timeIntervalSinceNow: -60) {
            throw AuthFlowError.emailAlreadyRegistered
        }
    }
    
    func verifyEmailOTP(
        email: String,
        token: String,
        nickname: String?
    ) async throws(AuthFlowError) {
        let newSession: Session
        
        do {
            let response = try await client
                .auth
                .verifyOTP(email: email, token: token, type: .signup)
            
            guard let session = response.session else { throw AuthFlowError.invalidCode }
            newSession = session
            
        } catch let error as AuthFlowError {
            throw error
        } catch {
            throw AuthFlowError.map(error)
        }
        
        session = newSession
        notePasswordAuth()
        profileSync.registerLocalIdentity(nickname: nickname)
    }
    
    func resendSignUpCode(email: String) async throws(AuthFlowError) {
        do {
            try await client
                .auth
                .resend(email: email, type: .signup)
        } catch {
            throw AuthFlowError.map(error)
        }
    }
    
    func signIn(email: String, password: String) async throws(AuthFlowError) {
        let newSession: Session
        
        do {
            newSession = try await client
                .auth
                .signIn(email: email, password: password)
        } catch {
            throw AuthFlowError.map(error)
        }
        
        session = newSession
        notePasswordAuth()
    }
    
    func signInWithApple(
        idToken: String,
        nonce: String,
        fullName: String?
    ) async throws(AuthFlowError) {
        let newSession: Session
        
        do {
            newSession = try await client
                .auth
                .signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
                )
        } catch {
            throw AuthFlowError.map(error)
        }
        
        session = newSession
        
        if let fullName, !fullName.isEmpty {
            profileSync.registerLocalIdentity(nickname: fullName)
        }
    }
    
    func requestPasswordReset(email: String) async throws(AuthFlowError) {
        do {
            try await client
                .auth
                .resetPasswordForEmail(email)
        } catch {
            throw AuthFlowError.map(error)
        }
    }
    
    func resetPassword(
        email: String,
        code: String,
        newPassword: String
    ) async throws(AuthFlowError) {
        let recovery = SupabaseService.makeEphemeralClient()
        do {
            let response = try await recovery
                .auth
                .verifyOTP(email: email, token: code, type: .recovery)
            guard response.session != nil else { throw AuthFlowError.invalidCode }
            
            try await recovery
                .auth
                .update(user: UserAttributes(password: newPassword))
            try? await recovery
                .auth
                .signOut(scope: .global)
        } catch let error as AuthFlowError {
            throw error
        } catch {
            throw AuthFlowError.map(error)
        }
        
        try await signIn(email: email, password: newPassword)
    }
    
    func verifyPassword(_ password: String) async throws(AuthFlowError) {
        guard let email = session?.user.email else { throw AuthFlowError.unknown }
        
        let verifier = SupabaseService.makeEphemeralClient()
        
        do {
            _ = try await verifier
                .auth
                .signIn(email: email, password: password)
        } catch {
            throw AuthFlowError.map(error)
        }
        
        try? await verifier
            .auth
            .signOut(scope: .local)
        
        notePasswordAuth()
    }
    
    func verifyAppleCredential(idToken: String, nonce: String) async throws(AuthFlowError) {
        guard let currentUserID = session?.user.id else { throw AuthFlowError.unknown }
        
        let verifier = SupabaseService.makeEphemeralClient()
        let verified: Session
        
        do {
            verified = try await verifier
                .auth
                .signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
                )
        } catch {
            throw AuthFlowError.map(error)
        }
        
        try? await verifier
            .auth
            .signOut(scope: .local)
        
        guard verified.user.id == currentUserID else {
            throw AuthFlowError.invalidCredentials
        }
    }
    
    func changePassword(current: String, new: String) async throws(AuthFlowError) {
        try await verifyPassword(current)
        
        do {
            try await client
                .auth
                .update(user: UserAttributes(password: new))
            try? await client
                .auth
                .signOut(scope: .others)
        } catch {
            throw AuthFlowError.map(error)
        }
    }
    
    func signOut() async {
        do {
            try await client
                .auth
                .signOut(scope: .local)
        } catch {
        }
        if session != nil {
            session = nil
            appDataLoader.handleSignedOut()
        }
    }
    
    func deleteAccount() async throws(AuthFlowError) {
        do {
            try await client
                .functions
                .invoke("delete-account")
        } catch {
            throw AuthFlowError.map(error)
        }
        progressSync.wipeForAccountDeletion()
        
        try? await client
            .auth
            .signOut(scope: .local)
        if session != nil {
            session = nil
            appDataLoader.handleSignedOut()
        }
    }
    
    func validateSessionOnServer() async {
        guard isAuthenticated else { return }
        
        let client = client
        let timeout = validationTimeout
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { _ = try await client.auth.refreshSession() }
                group.addTask {
                    try await Task.sleep(for: .seconds(timeout))
                    throw URLError(.timedOut)
                }
                try await group.next()
                group.cancelAll()
            }
        } catch let error as AuthError {
            switch error.errorCode {
            case .userBanned:
                pendingBanNotice = true
                await signOut()
            case .userNotFound, .sessionNotFound, .badJWT, .refreshTokenNotFound:
                await signOut()
            default:
                if error.localizedDescription.lowercased().contains("banned") {
                    pendingBanNotice = true
                    await signOut()
                }
            }
        } catch {
        }
    }
    
    func consumeBanNotice() -> Bool {
        guard pendingBanNotice else { return false }
        pendingBanNotice = false
        return true
    }
    
    private func handle(event: AuthChangeEvent, session: Session?) {
        switch event {
        case .initialSession:
            self.session = session
            syncRevenueCatIdentity()
        case .tokenRefreshed, .userUpdated:
            self.session = session
        case .signedIn:
            self.session = session
            appDataLoader.handleSignedIn()
            syncRevenueCatIdentity()
        case .signedOut, .userDeleted:
            self.session = nil
            appDataLoader.handleSignedOut()
            syncRevenueCatIdentity()
        default:
            break
        }
    }
    
    private func hasIdentity(provider: String) -> Bool {
        session?.user.identities?.contains { $0.provider == provider } ?? false
    }
    
    private var metadataProviders: [String] {
        session?
            .user
            .appMetadata["providers"]?
            .arrayValue?
            .compactMap(\.stringValue) ?? []
    }
    
    private var isKnownPasswordUser: Bool {
        guard let id = userID?.uuidString else { return false }
        return knownPasswordUserIDs.contains(id)
    }
    
    private var knownPasswordUserIDs: Set<String> {
        Set(userDefaults.stringArray(forKey: AppStorageKey.passwordAuthUserIDs.key) ?? [])
    }
    
    private func notePasswordAuth() {
        guard let id = userID?.uuidString else { return }
        
        var ids = knownPasswordUserIDs
        guard ids.insert(id).inserted else { return }
        userDefaults.set(Array(ids), forKey: AppStorageKey.passwordAuthUserIDs.key)
    }
    
    private func syncRevenueCatIdentity() {
        let appUserID = session?.user.id.uuidString
        
        Task {
            if let appUserID {
                guard Purchases.shared.appUserID != appUserID else { return }
                _ = try? await Purchases.shared.logIn(appUserID)
            } else {
                guard !Purchases.shared.isAnonymous else { return }
                _ = try? await Purchases.shared.logOut()
            }
        }
    }
}
