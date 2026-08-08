//
//  ProfileService.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

struct ProfileService: Sendable {
    static let shared = ProfileService()
    
    private let client = SupabaseService.client
    
    private init() {}
    
    func fetchIdentity(userID: UUID) async throws -> ProfileIdentity? {
        let response = try await client
            .from("profiles")
            .select("email,nickname,avatar_url,language,mood,user_data_updated_at")
            .eq("id", value: userID)
            .execute()
        
        let rows = try JSONDecoder()
            .decode([ProfileIdentity].self, from: response.data)
        
        return rows.first
    }
    
    func pushIdentity(
        userID: UUID,
        email: String?,
        nickname: String?,
        avatarURL: String?,
        language: String?,
        mood: String?,
        editedAt: Date
    ) async throws {
        let dto = IdentityUpsertDTO(
            id: userID,
            email: email,
            nickname: nickname,
            avatarURL: avatarURL,
            language: language,
            mood: mood,
            userDataUpdatedAt: editedAt
        )
        
        try await client
            .from("profiles")
            .upsert(dto, onConflict: "id")
            .execute()
    }
}

private struct IdentityUpsertDTO: Encodable {
    let id: UUID
    let email: String?
    let nickname: String?
    let avatarURL: String?
    let language: String?
    let mood: String?
    let userDataUpdatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, nickname, language, mood
        case avatarURL = "avatar_url"
        case userDataUpdatedAt = "user_data_updated_at"
    }
}
