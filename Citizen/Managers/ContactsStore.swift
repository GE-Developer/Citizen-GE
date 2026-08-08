//
//  ContactsStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ContactsStore {
    private(set) var contacts: [Contact]
    
    static let shared = ContactsStore()
    
    private let service = ContactsService.shared
    private let userDefaults = UserDefaults.standard
    
    private init() {
        contacts = Self.readFromDisk()
    }
    
    func syncIfChanged() async throws {
        let probe = try await service.fetchProbe()
        let latestToken = probe.latest ?? ""
        
        let storedToken = userDefaults
            .string(forKey: AppStorageKey.contactsUpdatedAt.key) ?? ""
        let storedCount = userDefaults
            .integer(forKey: AppStorageKey.contactsCount.key)
        
        let changed = contacts.isEmpty
        || latestToken != storedToken
        || probe.count != storedCount
        guard changed else { return }
        
        let fresh = try await service.fetchAll()
        contacts = fresh
        writeToDisk(fresh)
        userDefaults.set(latestToken, forKey: AppStorageKey.contactsUpdatedAt.key)
        userDefaults.set(probe.count, forKey: AppStorageKey.contactsCount.key)
    }
    
    func wipe() {
        try? FileManager.default.removeItem(at: Self.fileURL)
        contacts = []
        userDefaults.removeObject(forKey: AppStorageKey.contactsUpdatedAt.key)
        userDefaults.removeObject(forKey: AppStorageKey.contactsCount.key)
    }
    
    private func writeToDisk(_ contacts: [Contact]) {
        let url = Self.fileURL
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(contacts)
            try data.write(to: url, options: .atomic)
        } catch {
        }
    }
    
    nonisolated private static var fileURL: URL {
        FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Contacts")
            .appendingPathComponent("contacts.json")
    }
    
    nonisolated private static func readFromDisk() -> [Contact] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder()
            .decode([Contact].self, from: data)) ?? []
    }
}
