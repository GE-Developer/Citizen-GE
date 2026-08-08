//
//  LeaderboardEntry.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct LeaderboardEntry: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    let nickname: String?
    let avatarURL: String?
    let scores: Int
    let progressPercent: Int
    let isPremium: Bool
    let mood: String?
    
    enum CodingKeys: String, CodingKey {
        case id, nickname, scores, mood
        case avatarURL = "avatar_url"
        case progressPercent = "progress_percent"
        case isPremium = "is_premium"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL)
        scores = try container.decode(Int.self, forKey: .scores)
        progressPercent = try container.decode(Int.self, forKey: .progressPercent)
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        mood = (try? container.decodeIfPresent(String.self, forKey: .mood)) ?? nil
    }
}
