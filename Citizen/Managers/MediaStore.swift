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
    
    @ObservationIgnored private var imageCaches: [ImageVariant: [String: CGImage]] = [:]
    @ObservationIgnored private var imageCacheOrders: [ImageVariant: [String]] = [:]
    
    private var inflight: [String: Task<URL, Error>] = [:]
    private var failedFetches: Set<String> = []
    private var decodeTasks: [String: Task<CGImage?, Never>] = [:]
    private var alphabetPrefetchTask: Task<Void, Never>?
    private var questionPrefetchTask: Task<Void, Never>?
    
    static let shared = MediaStore()
    
    private let prefetchConcurrency = 4
    private let mediaHeadroomBytes: Int64 = 100 * 1024 * 1024
    
    private init() {}
    
    enum ImageVariant {
        case full
        case thumbnail
        
        var maxPixelSize: Int {
            switch self {
            case .full: return 1024
            case .thumbnail: return 256
            }
        }
        
        var cacheLimit: Int {
            switch self {
            case .full: return 20
            case .thumbnail: return 60
            }
        }
    }
    
    enum FetchPriority {
        case background
        case interactive
    }
    
    func configure() {
        NetworkMonitor.shared.onRestore { [weak self] in
            Task { await self?.prefetchAlphabetMedia() }
            Task { await self?.prefetchQuestionMedia() }
        }
    }
    
    // MARK: - Versions
    func syncVersions(server: [String: Int]) {
        var stored = storedVersions()
        let groups = Dictionary(grouping: MediaKind.allCases, by: \.versionRow)
        
        for (row, groupKinds) in groups {
            guard let serverVersion = server[row],
                  serverVersion > stored[row] ?? 0 else { continue }
            
            for folder in Set(groupKinds.map(\.folder)) {
                try? FileManager.default.removeItem(at: folderURL(folder))
            }
            
            clearImageCache()
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
        alphabetPrefetchTask?.cancel()
        questionPrefetchTask?.cancel()
        failedFetches = []
        
        let base = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        try? FileManager
            .default
            .removeItem(at: base.appendingPathComponent("Media", isDirectory: true))
        
        clearImageCache()
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
    
    func fetch(_ kind: MediaKind, name: String, priority: FetchPriority = .background) async throws -> URL {
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
        let session = Self.session(for: priority)
        
        let task = Task<URL, Error> {
            do {
                let url = try await Self.performFetch(
                    remote: remote,
                    folder: folder,
                    destination: destination,
                    headroomBytes: headroom,
                    name: name,
                    session: session
                )
                self.failedFetches.remove(key)
                
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
    
    @discardableResult
    func fetchWithTimeout(
        _ kind: MediaKind,
        name: String,
        priority: FetchPriority,
        timeout: TimeInterval
    ) async -> URL? {
        await withCheckedContinuation { (continuation: CheckedContinuation<URL?, Never>) in
            var isResolved = false
            
            let fetchTask = Task {
                let result = try? await self.fetch(kind, name: name, priority: priority)
                guard !isResolved else { return }
                isResolved = true
                continuation.resume(returning: result)
            }
            
            Task {
                try? await Task.sleep(for: .seconds(timeout))
                guard !isResolved else { return }
                isResolved = true
                fetchTask.cancel()
                continuation.resume(returning: nil)
            }
        }
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
        if let existing = alphabetPrefetchTask {
            return await existing.value
        }
        
        let task = Task { await runAlphabetPrefetch() }
        alphabetPrefetchTask = task
        defer { alphabetPrefetchTask = nil }
        
        await task.value
    }
    
    func prefetchQuestionMedia() async {
        if let existing = questionPrefetchTask {
            return await existing.value
        }
        
        let task = Task { await runQuestionPrefetch() }
        questionPrefetchTask = task
        defer { questionPrefetchTask = nil }
        
        await task.value
    }
    
    private func runAlphabetPrefetch() async {
        failedFetches = []
        var files: [(kind: MediaKind, name: String)] = []
        
        for letter in AlphabetCatalog.shared.letters {
            files.append((.alphabetImage, letter.exampleImage))
            files.append((.alphabetLetterAudio, letter.letterAudio))
            files.append((.alphabetExampleAudio, letter.exampleAudio))
        }
        await prefetch(files)
    }
    
    private func runQuestionPrefetch() async {
        var images: [(kind: MediaKind, name: String)] = []
        var audio: [(kind: MediaKind, name: String)] = []
        
        for category in QuizRepository.shared.catalog.categories {
            for topic in category.topics {
                for question in topic.questions {
                    if let image = question.imageUrl {
                        images.append((.questionImage, image))
                    }
                    if let file = question.audioUrl {
                        audio.append((.questionAudio, file))
                    }
                    if let file = question.additionalAudioUrl {
                        audio.append((.questionAudio, file))
                    }
                    for answer in question.answers {
                        if let image = answer.imageUrl {
                            images.append((.questionImage, image))
                        }
                        if let file = answer.audioUrl {
                            audio.append((.questionAudio, file))
                        }
                    }
                }
            }
        }
        
        await prefetch(images + audio)
    }
    
    func cachedImage(_ kind: MediaKind, name: String, variant: ImageVariant = .full) -> CGImage? {
        let key = "\(kind.folder)/\(name)"
        
        if let image = imageCaches[variant]?[key] {
            return image
        }
        
        guard variant == .thumbnail else { return nil }
        
        return imageCaches[.full]?[key]
    }
    
    func prepareImages(for questions: [Question]) {
        let names = questions.flatMap { question in
            (question.imageUrl.map { [$0] } ?? []) + question.answers.compactMap(\.imageUrl)
        }
        
        for name in Set(names) {
            let key = "\(MediaKind.questionImage.folder)/\(name)"
            
            guard cachedImage(.questionImage, name: name) == nil,
                  !failedFetches.contains(key) else { continue }
            
            Task { _ = await self.loadImage(.questionImage, name: name) }
        }
    }
    
    func loadImage(_ kind: MediaKind, name: String, variant: ImageVariant = .full) async -> CGImage? {
        let key = "\(kind.folder)/\(name)"
        let decodeKey = "\(key)@\(variant.maxPixelSize)"
        
        if let cached = cachedImage(kind, name: name, variant: variant) {
            return cached
        }
        
        if let task = decodeTasks[decodeKey] {
            return await task.value
        }
        
        let maxPixelSize = variant.maxPixelSize
        
        let task = Task<CGImage?, Never> { [weak self] in
            guard let self else { return nil }
            
            var url = self.localURL(kind, name: name)
            
            if url == nil {
                url = try? await self.fetch(kind, name: name)
            }
            
            guard let url else { return nil }
            
            let decoded = await Task.detached(priority: .userInitiated) {
                Self.decodeImage(at: url, maxPixelSize: maxPixelSize)
            }.value
            
            guard let decoded else {
                self.failedFetches.insert(key)
                return nil
            }
            
            self.cacheImage(decoded, forKey: key, variant: variant)
            
            return decoded
        }
        
        decodeTasks[decodeKey] = task
        defer { decodeTasks[decodeKey] = nil }
        
        return await task.value
    }
    
    // MARK: - Image cache
    private func cacheImage(_ image: CGImage, forKey key: String, variant: ImageVariant) {
        var cache = imageCaches[variant] ?? [:]
        var order = imageCacheOrders[variant] ?? []
        
        if cache.updateValue(image, forKey: key) == nil {
            order.append(key)
        }
        
        while order.count > variant.cacheLimit {
            let evicted = order.removeFirst()
            cache.removeValue(forKey: evicted)
        }
        
        imageCaches[variant] = cache
        imageCacheOrders[variant] = order
    }
    
    private func clearImageCache() {
        for task in decodeTasks.values {
            task.cancel()
        }
        
        imageCaches = [:]
        imageCacheOrders = [:]
        decodeTasks = [:]
    }
    
    // MARK: - Download plumbing
    private nonisolated static func decodeImage(at url: URL, maxPixelSize: Int) -> CGImage? {
        let sourceOptions: [CFString: Any] = [kCGImageSourceShouldCache: false]
        
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions as CFDictionary) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
    
    private nonisolated static let interactiveSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.networkServiceType = .responsiveData
        configuration.timeoutIntervalForRequest = 15
        return URLSession(configuration: configuration)
    }()
    
    private nonisolated static let backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 2
        configuration.networkServiceType = .background
        return URLSession(configuration: configuration)
    }()
    
    private nonisolated static func session(for priority: FetchPriority) -> URLSession {
        switch priority {
        case .interactive: return interactiveSession
        case .background: return backgroundSession
        }
    }
    
    private nonisolated static func performFetch(
        remote: URL,
        folder: URL,
        destination: URL,
        headroomBytes: Int64,
        name: String,
        session: URLSession
    ) async throws -> URL {
        guard DiskSpace.hasHeadroom(headroomBytes) else {
            throw DiskSpace.outOfSpaceError
        }
        
        var request = URLRequest(url: remote)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let (data, response) = try await session.data(for: request)
        
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
        folderURL(kind.folder)
    }
    
    private nonisolated func folderURL(_ folder: String) -> URL {
        let base = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        return base
            .appendingPathComponent("Media", isDirectory: true)
            .appendingPathComponent(folder, isDirectory: true)
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
