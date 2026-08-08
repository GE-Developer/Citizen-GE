//
//  ProfileIdentity.swift
//  Citizen
//
//  Created by GE-Developer
//

struct ProfileIdentity: Decodable, Sendable {
    let email: String?
    let nickname: String?
    let avatarURL: String?
    let language: String?
    let mood: String?
    let userDataUpdatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case email, nickname, language, mood
        case avatarURL = "avatar_url"
        case userDataUpdatedAt = "user_data_updated_at"
    }
}
