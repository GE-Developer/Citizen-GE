//
//  MediaStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import ImageIO

@MainActor
@Observable
final class MediaStore {
    private(set) var revision = 0
    
    private var imageCache: [String: CGImage] = [:]
    private var inflight: [String: Task<URL, Error>] = [:]
    private var failedFetches: Set<String> = []
    private var decodingImages: Set<String> = []
    
    static let shared = MediaStore()
    
    private let prefetchConcurrency = 4
    private let mediaHeadroomBytes: Int64 = 100 * 1024 * 1024
    
    private init() {}
    
    func configure() {
        NetworkMonitor.shared.onRestore { [weak self] in
            Task { await self?.prefetchAlphabetMedia() }
            Task { await self?.prefetchQuestionAudio() }
        }
    }
    
    // MARK: - Versions
    func syncVersions(server: [String: Int]) {
        var stored = storedVersions()
        let kinds: [MediaKind] = [
            .alphabetImage,
            .alphabetLetterAudio,
            .alphabetExampleAudio,
            .questionAudio
        ]
        let groups = Dictionary(grouping: kinds, by: \.versionRow)
        
        for (row, groupKinds) in groups {
            guard let serverVersion = server[row],
                  serverVersion > stored[row] ?? 0 else { continue }
            for kind in groupKinds {
                try? FileManager.default.removeItem(at: folderURL(kind))
            }
            
            imageCache = [:]
            decodingImages = []
            failedFetches = []
            
            stored[row] = serverVersion
            setStoredVersions(stored)
            revision += 1
            
        }
    }
    
    func wipeAllMedia() {
        for task in inflight.values {
            task.cancel()
        }
        
        inflight = [:]
        failedFetches = []
        
        let base = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        try? FileManager
            .default
            .removeItem(at: base.appendingPathComponent("Media", isDirectory: true))
        
        imageCache = [:]
        decodingImages = []
        UserDefaults.standard.removeObject(forKey: AppStorageKey.mediaVersions.key)
        
        revision += 1
        
    }
    
    // MARK: - Access
    nonisolated func localURL(_ kind: MediaKind, name: String) -> URL? {
        let url = fileURL(kind, name: name)
        return FileManager
            .default
            .fileExists(atPath: url.path) ? url : nil
    }
    
    func fetch(_ kind: MediaKind, name: String) async throws -> URL {
        if let url = localURL(kind, name: name) {
            return url
        }
        
        let key = "\(kind.folder)/\(name)"
        
        if let task = inflight[key] {
            return try await task.value
        }
        
        let remote = try remoteURL(kind, name: name)
        let folder = folderURL(kind)
        let destination = fileURL(kind, name: name)
        let headroom = mediaHeadroomBytes
        
        let task = Task<URL, Error> {
            do {
                let url = try await Self.performFetch(
                    remote: remote,
                    folder: folder,
                    destination: destination,
                    headroomBytes: headroom,
                    name: name
                )
                self.failedFetches.remove(key)
                
                if kind.isDisplayed {
                    self.revision += 1
                }
                
                return url
            } catch {
                self.failedFetches.insert(key)
                throw error
            }
        }
        
        inflight[key] = task
        defer { inflight[key] = nil }
        
        return try await task.value
    }
    
    func prefetch(_ files: [(kind: MediaKind, name: String)]) async {
        let missing = await Task.detached(priority: .utility) { [self] in
            files.filter { localURL($0.kind, name: $0.name) == nil }
        }.value
        
        guard !missing.isEmpty else { return }
        
        await withTaskGroup(of: Void.self) { group in
            var iterator = missing.makeIterator()
            
            for _ in 0..<prefetchConcurrency {
                guard let file = iterator.next() else { break }
                group.addTask { _ = try? await self.fetch(file.kind, name: file.name) }
            }
            
            while await group.next() != nil {
                guard let file = iterator.next() else { continue }
                group.addTask { _ = try? await self.fetch(file.kind, name: file.name) }
            }
        }
    }
    
    func prefetchAlphabetMedia() async {
        failedFetches = []
        var files: [(kind: MediaKind, name: String)] = []
        
        for letter in AlphabetCatalog.shared.letters {
            files.append((.alphabetImage, letter.exampleImage))
            files.append((.alphabetLetterAudio, letter.letterAudio))
            files.append((.alphabetExampleAudio, letter.exampleAudio))
        }
        await prefetch(files)
    }
    
    func prefetchQuestionAudio() async {
        var files: [(kind: MediaKind, name: String)] = []
        
        for category in QuizRepository.shared.catalog.categories {
            for topic in category.topics {
                for question in topic.questions {
                    if let audio = question.audioUrl {
                        files.append((.questionAudio, audio))
                    }
                    if let audio = question.additionalAudioUrl {
                        files.append((.questionAudio, audio))
                    }
                    for answer in question.answers {
                        if let audio = answer.audioUrl {
                            files.append((.questionAudio, audio))
                        }
                    }
                }
            }
        }
        
        await prefetch(files)
    }
    
    func image(_ kind: MediaKind, name: String) -> CGImage? {
        _ = revision
        let key = "\(kind.folder)/\(name)"
        
        if let cached = imageCache[key] {
            return cached
        }
        
        guard let url = localURL(kind, name: name) else {
            if inflight[key] == nil, !failedFetches.contains(key) {
                Task { _ = try? await self.fetch(kind, name: name) }
            }
            
            return nil
        }
        
        if !decodingImages.contains(key) {
            decodingImages.insert(key)
            Task { [weak self] in
                let decoded = await Task.detached(priority: .userInitiated) {
                    Self.decodeImage(at: url)
                }.value
                
                guard let self else { return }
                self.decodingImages.remove(key)
                guard let decoded else {
                    self.failedFetches.insert(key)
                    self.revision += 1
                    return
                }
                self.imageCache[key] = decoded
                self.revision += 1
            }
        }
        
        return nil
    }
    
    func isLoading(_ kind: MediaKind, name: String) -> Bool {
        let key = "\(kind.folder)/\(name)"
        return inflight[key] != nil || !failedFetches.contains(key)
    }
    
    // MARK: - Download plumbing
    private nonisolated static func decodeImage(at url: URL) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
    
    private nonisolated static func performFetch(
        remote: URL,
        folder: URL,
        destination: URL,
        headroomBytes: Int64,
        name: String
    ) async throws -> URL {
        guard DiskSpace.hasHeadroom(headroomBytes) else {
            throw DiskSpace.outOfSpaceError
        }
        
        var request = URLRequest(url: remote)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200, !data.isEmpty else {
            throw ResourceError.loadFailed(name)
        }
        
        let fileManager = FileManager.default
        let parent = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        
        var mediaRoot = folder
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        
        try? mediaRoot.setResourceValues(resourceValues)
        
        let temp = parent.appendingPathComponent(destination.lastPathComponent + ".tmp")
        
        try data.write(to: temp, options: .atomic)
        _ = try fileManager.replaceItemAt(destination, withItemAt: temp)
        
        return destination
    }
    
    private func remoteURL(_ kind: MediaKind, name: String) throws -> URL {
        guard var components = URLComponents(string: Plist.get(.supabaseProjectUrl)) else {
            throw ResourceError.loadFailed(name)
        }
        
        components.path = "/storage/v1/object/public/Media/\(kind.folder)/\(name)"
        
        let version = storedVersions()[kind.versionRow] ?? 0
        components.queryItems = [URLQueryItem(name: "v", value: String(version))]
        
        guard let url = components.url else { throw ResourceError.loadFailed(name) }
        return url
    }
    
    private nonisolated func folderURL(_ kind: MediaKind) -> URL {
        let base = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        return base
            .appendingPathComponent("Media", isDirectory: true)
            .appendingPathComponent(kind.folder, isDirectory: true)
    }
    
    private nonisolated func fileURL(_ kind: MediaKind, name: String) -> URL {
        folderURL(kind).appendingPathComponent(name)
    }
    
    private func storedVersions() -> [String: Int] {
        guard let data = UserDefaults.standard.data(forKey: AppStorageKey.mediaVersions.key),
              let versions = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        
        return versions
    }
    
    private func setStoredVersions(_ versions: [String: Int]) {
        guard let data = try? JSONEncoder().encode(versions) else { return }
        UserDefaults.standard.set(data, forKey: AppStorageKey.mediaVersions.key)
    }
}
