//
//  LeaderboardService.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

struct LeaderboardService: Sendable {
    static let shared = LeaderboardService()
    
    private let client = SupabaseService.client
    
    private init() {}
    
    func fetchTop(maxRows: Int = 500) async throws -> [LeaderboardEntry] {
        let response = try await client
            .from("leaderboard")
            .select("id,nickname,avatar_url,scores,progress_percent,is_premium,mood")
            .order("scores", ascending: false)
            .order("nickname", ascending: true, nullsFirst: false)
            .order("id", ascending: true)
            .limit(maxRows)
            .execute()
        
        return try JSONDecoder()
            .decode([LeaderboardEntry].self, from: response.data)
    }
}
