//
//  GrantManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

struct Grant: Decodable, Sendable {
    let hasGrant: Bool
    let password: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case password, message
        case hasGrant = "has_grant"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasGrant = try container.decodeIfPresent(Bool.self, forKey: .hasGrant) ?? false
        
        if let text = try? container.decode(String.self, forKey: .password) {
            password = text
        } else if let number = try? container.decode(Int.self, forKey: .password) {
            password = String(number)
        } else {
            password = nil
        }
        
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}

struct GrantService: Sendable {
    static let shared = GrantService()
    
    private let client = SupabaseService.client
    
    private init() {}
    
    func fetchGrant(userID: UUID) async throws -> Grant? {
        let response = try await client
            .from("grants")
            .select("has_grant,password,message")
            .eq("id", value: userID)
            .execute()
        
        let rows = try JSONDecoder()
            .decode([Grant].self, from: response.data)
        return rows.first
    }
}

@MainActor
@Observable
final class GrantManager {
    private(set) var hasGrant: Bool
    private(set) var devPassword: String?
    private(set) var message: String?
    
    private var authManager: AuthManager { .shared }
    
    static let shared = GrantManager()
    
    private let service = GrantService.shared
    private let userDefaults = UserDefaults.standard
    private let fetchTimeout: TimeInterval = 2
    
    private init() {
        hasGrant = userDefaults.bool(forKey: AppStorageKey.grantPremium.key)
        devPassword = userDefaults.string(forKey: AppStorageKey.grantDevPassword.key)
        message = userDefaults.string(forKey: AppStorageKey.grantMessage.key)
    }
    
    func syncOnLoad() async {
        guard let userID = authManager.userID else { return }
        
        let grant: Grant?
        do {
            grant = try await fetchGrantBounded()
        } catch {
            return
        }
        
        guard authManager.userID == userID else {
            return
        }
        
        apply(grant)
    }
    
    func handleSignedOut() {
        hasGrant = false
        devPassword = nil
        message = nil
        userDefaults.removeObject(forKey: AppStorageKey.grantPremium.key)
        userDefaults.removeObject(forKey: AppStorageKey.grantDevPassword.key)
        userDefaults.removeObject(forKey: AppStorageKey.grantMessage.key)
    }
    
    // MARK: - Private
    private func apply(_ grant: Grant?) {
        hasGrant = grant?.hasGrant ?? false
        devPassword = grant?.password
        message = grant?.message
        
        userDefaults.set(hasGrant, forKey: AppStorageKey.grantPremium.key)
        setOrRemove(devPassword, forKey: AppStorageKey.grantDevPassword.key)
        setOrRemove(message, forKey: AppStorageKey.grantMessage.key)
    }
    
    private func setOrRemove(_ value: String?, forKey key: String) {
        if let value {
            userDefaults.set(value, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    private func fetchGrantBounded() async throws -> Grant? {
        guard let userID = authManager.userID else { return nil }
        
        let timeout = fetchTimeout
        let service = service
        
        return try await withThrowingTaskGroup(of: Grant?.self) { group in
            group.addTask { try await service.fetchGrant(userID: userID) }
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw URLError(.timedOut)
            }
            
            guard let grant = try await group.next() else { throw URLError(.unknown) }
            
            group.cancelAll()
            return grant
        }
    }
}
