//
//  RemoteImageStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreGraphics
import CryptoKit
import Foundation
import ImageIO

@MainActor
@Observable
final class RemoteImageStore {
    private var inflight: [String: Task<SendableImage?, Never>] = [:]
    
    static let shared = RemoteImageStore()
    nonisolated private static let maxPixelSize = 200
    
    private let memory: NSCache<NSString, CGImage> = {
        let cache = NSCache<NSString, CGImage>()
        cache.countLimit = 200
        return cache
    }()
    
    private init() {}
    
    func image(for url: String) async -> CGImage? {
        if let cached = memory.object(forKey: url as NSString) { return cached }
        if let task = inflight[url] { return await task.value?.image }
        
        let task = Task.detached(priority: .userInitiated) { () -> SendableImage? in
            if let disk = Self.decodeFromDisk(url) {
                return disk
            }
            
            guard let data = try? await AvatarService.shared.download(from: url) else {
                return nil
            }
            
            Self.writeToDisk(data, for: url)
            return Self.decode(data)
        }
        
        inflight[url] = task
        let boxed = await task.value
        inflight[url] = nil
        
        if let image = boxed?.image {
            memory.setObject(image, forKey: url as NSString)
        }
        
        return boxed?.image
    }
    
    func wipeAll() {
        for task in inflight.values {
            task.cancel()
        }
        
        inflight = [:]
        memory.removeAllObjects()
        
        let base = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        try? FileManager
            .default
            .removeItem(at: base.appendingPathComponent("RemoteImages", isDirectory: true))
        
    }
    
    // MARK: - Disk
    nonisolated private static func fileURL(for url: String) -> URL {
        let name = SHA256
            .hash(data: Data(url.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RemoteImages")
            .appendingPathComponent("\(name).img")
    }
    
    nonisolated private static func decodeFromDisk(_ url: String) -> SendableImage? {
        guard let data = try? Data(contentsOf: fileURL(for: url)) else { return nil }
        return decode(data)
    }
    
    nonisolated private static func writeToDisk(_ data: Data, for url: String) {
        let dest = fileURL(for: url)
        
        do {
            try FileManager
                .default
                .createDirectory(
                    at: dest.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            try data.write(to: dest, options: .atomic)
            
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            
            var mutableDest = dest
            
            try? mutableDest.setResourceValues(values)
        } catch {
        }
    }
    
    nonisolated private static func decode(_ data: Data) -> SendableImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return SendableImage(image: image)
    }
}

private struct SendableImage: @unchecked Sendable {
    let image: CGImage
}
