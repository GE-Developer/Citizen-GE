//
//  SupabaseService.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: anonKey,
        options: SupabaseClientOptions(
            auth: SupabaseClientOptions.AuthOptions(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
    
    static func makeEphemeralClient() -> SupabaseClient {
        SupabaseClient(
            supabaseURL: projectURL,
            supabaseKey: anonKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    storage: InMemoryAuthStorage(),
                    autoRefreshToken: false
                )
            )
        )
    }
    
    private static var projectURL: URL {
        guard let url = URL(string: Plist.get(.supabaseProjectUrl)) else {
            preconditionFailure("Supabase URL missing in Property List.plist")
        }
        return url
    }
    
    private static var anonKey: String {
        let key = Plist.get(.supabaseAnonKey)
        guard !key.isEmpty else {
            preconditionFailure("Supabase key missing in Property List.plist")
        }
        return key
    }
}

private final class InMemoryAuthStorage: AuthLocalStorage, @unchecked Sendable {
    private var values: [String: Data] = [:]
    private let lock = NSLock()
    
    func store(key: String, value: Data) throws {
        lock.withLock { values[key] = value }
    }
    
    func retrieve(key: String) throws -> Data? {
        lock.withLock { values[key] }
    }
    
    func remove(key: String) throws {
        lock.withLock { values[key] = nil }
    }
}
