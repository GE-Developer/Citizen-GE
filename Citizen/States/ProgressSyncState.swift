//
//  ProgressSyncState.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class ProgressSyncState {
    var isDirty: Bool {
        localChangeCount != syncedChangeCount
    }
    
    private(set) var localChangeCount: Int
    private(set) var syncedChangeCount: Int
    private(set) var lastLocalChangeAt: Date?
    private(set) var lastSyncedServerUpdatedAt: String?
    private(set) var lastSyncedUserID: String?
    
    static let shared = ProgressSyncState()
    
    private let defaults = UserDefaults.standard
    
    private init() {
        localChangeCount = defaults.integer(forKey: AppStorageKey.syncLocalChangeCount.key)
        syncedChangeCount = defaults.integer(forKey: AppStorageKey.syncSyncedChangeCount.key)
        
        let changedAt = defaults.double(forKey: AppStorageKey.syncLastLocalChangeAt.key)
        lastLocalChangeAt = changedAt > 0 ? Date(timeIntervalSince1970: changedAt) : nil
        lastSyncedServerUpdatedAt = defaults.string(forKey: AppStorageKey.syncServerUpdatedAt.key)
        lastSyncedUserID = defaults.string(forKey: AppStorageKey.syncLastUserID.key)
    }
    
    func noteLocalChange() {
        localChangeCount += 1
        lastLocalChangeAt = Date()
        
        defaults.set(localChangeCount, forKey: AppStorageKey.syncLocalChangeCount.key)
        defaults.set(
            lastLocalChangeAt?.timeIntervalSince1970 ?? 0,
            forKey: AppStorageKey.syncLastLocalChangeAt.key
        )
    }
    
    func markSynced(changeCount: Int, serverUpdatedAt: String, userID: UUID) {
        syncedChangeCount = changeCount
        lastSyncedServerUpdatedAt = serverUpdatedAt
        lastSyncedUserID = userID.uuidString
        
        defaults.set(syncedChangeCount, forKey: AppStorageKey.syncSyncedChangeCount.key)
        defaults.set(serverUpdatedAt, forKey: AppStorageKey.syncServerUpdatedAt.key)
        defaults.set(lastSyncedUserID, forKey: AppStorageKey.syncLastUserID.key)
    }
    
    func claimUser(_ userID: UUID) {
        lastSyncedUserID = userID.uuidString
        defaults.set(lastSyncedUserID, forKey: AppStorageKey.syncLastUserID.key)
    }
    
    func clearServerToken() {
        lastSyncedServerUpdatedAt = nil
        defaults.removeObject(forKey: AppStorageKey.syncServerUpdatedAt.key)
    }
    
    func clearAll() {
        localChangeCount = 0
        syncedChangeCount = 0
        lastLocalChangeAt = nil
        lastSyncedServerUpdatedAt = nil
        lastSyncedUserID = nil
        
        defaults.removeObject(forKey: AppStorageKey.syncLocalChangeCount.key)
        defaults.removeObject(forKey: AppStorageKey.syncSyncedChangeCount.key)
        defaults.removeObject(forKey: AppStorageKey.syncLastLocalChangeAt.key)
        defaults.removeObject(forKey: AppStorageKey.syncServerUpdatedAt.key)
        defaults.removeObject(forKey: AppStorageKey.syncLastUserID.key)
    }
    
    func resetForAccountSwitch(to userID: UUID) {
        localChangeCount = 0
        syncedChangeCount = 0
        
        lastLocalChangeAt = nil
        lastSyncedServerUpdatedAt = nil
        lastSyncedUserID = userID.uuidString
        
        defaults.set(0, forKey: AppStorageKey.syncLocalChangeCount.key)
        defaults.set(0, forKey: AppStorageKey.syncSyncedChangeCount.key)
        defaults.removeObject(forKey: AppStorageKey.syncLastLocalChangeAt.key)
        defaults.removeObject(forKey: AppStorageKey.syncServerUpdatedAt.key)
        defaults.set(lastSyncedUserID, forKey: AppStorageKey.syncLastUserID.key)
    }
}
