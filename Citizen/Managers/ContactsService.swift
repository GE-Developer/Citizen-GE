//
//  ContactsService.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

struct ContactsService: Sendable {
    static let shared = ContactsService()
    
    private let client = SupabaseService.client
    
    private init() {}
    
    func fetchProbe() async throws -> (latest: String?, count: Int) {
        let response = try await client
            .from("useful_contacts")
            .select("updated_at", head: false, count: .exact)
            .order("updated_at", ascending: false)
            .limit(1)
            .execute()
        
        let rows = try JSONDecoder()
            .decode([UpdatedAtRow].self, from: response.data)
        return (rows.first?.updatedAt, response.count ?? 0)
    }
    
    func fetchAll() async throws -> [Contact] {
        let response = try await client
            .from("useful_contacts")
            .select()
            .execute()
        
        return try JSONDecoder()
            .decode([Contact].self, from: response.data)
    }
}

private struct UpdatedAtRow: Decodable {
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
    }
}
