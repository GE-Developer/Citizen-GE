//
//  ResourceProvider.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

final class ResourceProvider: Sendable {
    var downloadsURL: URL {
        let base = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        return base.appendingPathComponent("Resources", isDirectory: true)
    }
    
    static let shared = ResourceProvider()
    
    private init() {}
    
    func data(forName name: String) -> Data? {
        let downloaded = downloadsURL.appendingPathComponent("\(name).json")
        
        if let data = try? Data(contentsOf: downloaded) {
            return data
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            return nil
        }
        
        return try? Data(contentsOf: url)
    }
    
    func hasLocal(_ name: String) -> Bool {
        FileManager.default.fileExists(
            atPath: downloadsURL.appendingPathComponent("\(name).json").path
        )
    }
    
    func saveDownloaded(_ data: Data, forName name: String) throws {
        let fileManager = FileManager.default
        
        try fileManager.createDirectory(
            at: downloadsURL,
            withIntermediateDirectories: true
        )
        
        let destination = downloadsURL.appendingPathComponent("\(name).json")
        let temp = downloadsURL.appendingPathComponent("\(name).json.tmp")
        
        try data.write(to: temp, options: .atomic)
        _ = try fileManager.replaceItemAt(destination, withItemAt: temp)
    }
    
    func removeAllDownloads() throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: downloadsURL.path) else { return }
        
        try fileManager.removeItem(at: downloadsURL)
    }
}
