//
//  EntitlementManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

struct Entitlement: Decodable, Sendable {
    let isPremium: Bool
    let productID: String?
    let expiresAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case isPremium = "is_premium"
        case productID = "product_id"
        case expiresAt = "expires_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        productID = (try? container.decodeIfPresent(String.self, forKey: .productID)) ?? nil
        
        let rawExpiry = (try? container.decodeIfPresent(String.self, forKey: .expiresAt)) ?? nil
        expiresAt = rawExpiry.flatMap(PostgresTimestamp.date(from:))
    }
}

struct EntitlementService: Sendable {
    static let shared = EntitlementService()
    
    private let client = SupabaseService.client
    
    private init() {}
    
    func fetchEntitlement(userID: UUID) async throws -> Entitlement? {
        let response = try await client
            .from("entitlements")
            .select("is_premium,product_id,expires_at")
            .eq("user_id", value: userID)
            .execute()
        
        let rows = try JSONDecoder()
            .decode([Entitlement].self, from: response.data)
        return rows.first
    }
}

@MainActor
@Observable
final class EntitlementManager {
    private(set) var isPremium: Bool
    
    private var authManager: AuthManager { .shared }
    
    static let shared = EntitlementManager()
    
    private let service = EntitlementService.shared
    private let userDefaults = UserDefaults.standard
    private let fetchTimeout: TimeInterval = 2
    
    private init() {
        isPremium = userDefaults.bool(forKey: AppStorageKey.serverPremium.key)
    }
    
    func syncOnLoad() async {
        guard let userID = authManager.userID else { return }
        
        let entitlement: Entitlement?
        do {
            entitlement = try await fetchEntitlementBounded()
        } catch {
            return
        }
        
        guard authManager.userID == userID else { return }
        
        apply(entitlement)
    }
    
    func handleSignedOut() {
        isPremium = false
        userDefaults.removeObject(forKey: AppStorageKey.serverPremium.key)
    }
    
    // MARK: - Private
    private func apply(_ entitlement: Entitlement?) {
        let isActive: Bool
        
        if let entitlement, entitlement.isPremium {
            isActive = entitlement.expiresAt.map { $0 > Date() } ?? true
        } else {
            isActive = false
        }
        
        isPremium = isActive
        userDefaults.set(isActive, forKey: AppStorageKey.serverPremium.key)
    }
    
    private func fetchEntitlementBounded() async throws -> Entitlement? {
        guard let userID = authManager.userID else { return nil }
        
        let timeout = fetchTimeout
        let service = service
        
        return try await withThrowingTaskGroup(of: Entitlement?.self) { group in
            group.addTask { try await service.fetchEntitlement(userID: userID) }
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw URLError(.timedOut)
            }
            
            guard let entitlement = try await group.next() else { throw URLError(.unknown) }
            
            group.cancelAll()
            return entitlement
        }
    }
}
