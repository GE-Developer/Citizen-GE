//
//  AvatarService.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

struct AvatarService: Sendable {
    static let shared = AvatarService()
    
    private let bucket = "Avatars"
    private let client = SupabaseService.client
    
    private init() {}
    
    func upload(userID: UUID, jpeg: Data) async throws -> String {
        let path = "\(userID.uuidString.lowercased())/avatar-\(UUID().uuidString.lowercased()).jpg"
        try await client.storage
            .from(bucket)
            .upload(
                path,
                data: jpeg,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg",
                    upsert: false
                )
            )
        
        return try client
            .storage
            .from(bucket)
            .getPublicURL(path: path)
            .absoluteString
    }
    
    func deleteAll(userID: UUID, except keepURL: String?) async {
        let folder = userID.uuidString.lowercased()
        
        let keepName = keepURL.flatMap { URL(string: $0)?.lastPathComponent }
        
        do {
            let files = try await client
                .storage
                .from(bucket)
                .list(path: folder)
            
            let toRemove = files
                .map(\.name)
                .filter { $0 != keepName }
                .map { "\(folder)/\($0)" }
            guard !toRemove.isEmpty else { return }
            
            try await client
                .storage
                .from(bucket)
                .remove(paths: toRemove)
        } catch {
        }
    }
    
    func download(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200, !data.isEmpty else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
}
