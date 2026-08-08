//
//  ResourceDownloader.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

protocol ResourceDownloading: Sendable {
    func ensureResources() async throws
}

final class ResourceDownloader: ResourceDownloading, Sendable {
    private var allContentNames: [String] {
        Language.allCases.flatMap { ["questions.\($0.id)", "words.\($0.id)"] } + ["alphabet"]
    }
    
    static let shared = ResourceDownloader()
    
    private let probeTimeout: TimeInterval = 2
    private let contentHeadroomBytes: Int64 = 20 * 1024 * 1024
    
    private init() {}
    
    func ensureResources() async throws {
        try invalidateDownloadsIfAppUpdated()
        try await refreshContent()
    }
    
    func wipeAllContent() {
        try? ResourceProvider.shared.removeAllDownloads()
        UserDefaults.standard.removeObject(forKey: AppStorageKey.contentVersions.key)
    }
    
    private func invalidateDownloadsIfAppUpdated() throws {
        let defaults = UserDefaults.standard
        let key = AppStorageKey.resourcesVersion.key
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        
        guard defaults.string(forKey: key) != current else { return }
        defaults.removeObject(forKey: AppStorageKey.contentVersions.key)
        
        try ResourceProvider.shared.removeAllDownloads()
        
        defaults.set(current, forKey: key)
    }
    
    // MARK: - Version-gated refresh
    private func refreshContent() async throws {
        let server: [String: Int]
        do {
            server = try await fetchServerVersions()
        } catch {
            return
        }
        
        do {
            try handleResetIfNeeded(server)
        } catch {
            return
        }
        
        if let contentVersion = server["content"] {
            for name in allContentNames where contentVersion > effectiveVersion(name) {
                do {
                    try await downloadAndStore(name: name, version: contentVersion)
                } catch {
                    guard DiskSpace.isOutOfSpace(error) else { continue }
                    guard ResourceProvider.shared.hasLocal(name) else { throw error }
                    break
                }
            }
        }
        
        await MediaStore.shared.syncVersions(server: server)
    }
    
    private func fetchServerVersions() async throws -> [String: Int] {
        let timeout = probeTimeout
        
        return try await withThrowingTaskGroup(of: [String: Int].self) { group in
            group.addTask {
                let response = try await SupabaseService
                    .client
                    .from("content_versions")
                    .select("name,version")
                    .execute()
                let rows = try JSONDecoder().decode([ContentVersionRow].self, from: response.data)
                
                return Dictionary(rows.map { ($0.name, $0.version) }) { first, _ in first }
            }
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw URLError(.timedOut)
            }
            
            guard let versions = try await group.next() else { throw URLError(.unknown) }
            group.cancelAll()
            
            return versions
        }
    }
    
    private func handleResetIfNeeded(_ server: [String: Int]) throws {
        guard let serverReset = server["reset"],
              serverReset > effectiveVersion("reset") else { return }
        setStoredVersions([:])
        
        try ResourceProvider.shared.removeAllDownloads()
        
        setStoredVersions(["reset": serverReset])
    }
    
    private func downloadAndStore(name: String, version: Int) async throws {
        guard DiskSpace.hasHeadroom(contentHeadroomBytes) else {
            throw DiskSpace.outOfSpaceError
        }
        
        var request = URLRequest(url: try storageURL(name: name, version: version))
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ResourceError.loadFailed(name)
        }
        
        try validate(data, name: name)
        try ResourceProvider.shared.saveDownloaded(data, forName: name)
        
        var versions = storedVersions()
        versions[name] = version
        setStoredVersions(versions)
    }
    
    private func validate(_ data: Data, name: String) throws {
        let decoder = JSONDecoder()
        if name.hasPrefix("questions.") {
            let catalog = try decoder.decode(QuestionCatalog.self, from: data)
            if name == "questions.ka" {
                try QuizRepository.validate(catalog)
            }
        } else if name.hasPrefix("words.") {
            _ = try decoder.decode([String: WordEntry].self, from: data)
        } else if name == "alphabet" {
            _ = try decoder.decode([AlphabetLetter].self, from: data)
        } else {
            throw ResourceError.invalidData("unknown content name \(name)")
        }
    }
    
    private func storageURL(name: String, version: Int) throws -> URL {
        guard var components = URLComponents(string: Plist.get(.supabaseProjectUrl)) else {
            throw ResourceError.loadFailed(name)
        }
        components.path = "/storage/v1/object/public/Content/\(bucketFolder(name: name))/\(name).json"
        components.queryItems = [URLQueryItem(name: "v", value: String(version))]
        guard let url = components.url else { throw ResourceError.loadFailed(name) }
        return url
    }
    
    private func bucketFolder(name: String) -> String {
        if name.hasPrefix("questions.") {
            return "Questions"
        }
        
        if name.hasPrefix("words.") {
            return "Words"
        }
        
        return "Alphabet"
    }
    
    // MARK: - Local version bookkeeping
    private func effectiveVersion(_ name: String) -> Int {
        storedVersions()[name] ?? 0
    }
    
    private func storedVersions() -> [String: Int] {
        guard let data = UserDefaults.standard.data(forKey: AppStorageKey.contentVersions.key),
              let versions = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return versions
    }
    
    private func setStoredVersions(_ versions: [String: Int]) {
        guard let data = try? JSONEncoder().encode(versions) else { return }
        UserDefaults.standard.set(data, forKey: AppStorageKey.contentVersions.key)
    }
}

private struct ContentVersionRow: Decodable {
    let name: String
    let version: Int
}
