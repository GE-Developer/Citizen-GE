//
//  ProgressSync.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ProgressSync {
    private(set) var isSyncing = false
    private(set) var restoreCount = 0
    
    private var syncTask: Task<Void, Never>?
    private var rerunRequested = false
    private var debounceTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?
    private var failureCount = 0
    private var isFrozenForNewerSchema = false
    private var lastPassCompletedAt: Date?
    private var passGeneration = 0
    
    static let shared = ProgressSync()
    
    private let state = ProgressSyncState.shared
    private let service = ProgressService.shared
    private let stack = CoreDataStack.shared
    private let networkMonitor = NetworkMonitor.shared
    private let authManager = AuthManager.shared
    private let throttleInterval: TimeInterval = 30
    private let debounceInterval: TimeInterval = 5
    private let maxRetries = 3
    
    private let progressEntityNames = [
        "QuestionEntity",
        "GlobalMistakeEntity",
        "TopicStatsEntity",
        "SavedWordEntity",
        "QuestionFolderEntity",
        "SavedQuestionEntity"
    ]
    
    private init() {}
    
    func configure() {
        stack.onProgressMutation = { [weak self] in
            self?.state.noteLocalChange()
            self?.scheduleDebouncedPush()
        }
        
        networkMonitor.onRestore { [weak self] in
            self?.syncNow(.networkRestored)
        }
        
        networkMonitor.start()
    }
    
    func syncNow(_ trigger: SyncTrigger) {
        guard !isFrozenForNewerSchema else { return }
        guard authManager.isAuthenticated else { return }
        
        if trigger == .launch || trigger == .foreground,
           !state.isDirty,
           let last = lastPassCompletedAt,
           Date().timeIntervalSince(last) < throttleInterval {
            return
        }
        
        retryTask?.cancel()
        retryTask = nil
        
        if syncTask != nil {
            rerunRequested = true
            return
        }
        passGeneration += 1
        
        let generation = passGeneration
        isSyncing = true
        
        syncTask = Task {
            await runSyncPass(trigger)
            
            guard generation == passGeneration else { return }
            isSyncing = false
            syncTask = nil
            
            if rerunRequested {
                rerunRequested = false
                syncNow(.coalesced)
            }
        }
    }
    
    func scheduleDebouncedPush() {
        guard debounceTask == nil, authManager.isAuthenticated else { return }
        
        debounceTask = Task {
            try? await Task.sleep(for: .seconds(debounceInterval))
            let cancelled = Task.isCancelled
            debounceTask = nil
            
            guard !cancelled, state.isDirty else { return }
            syncNow(.debounce)
        }
    }
    
    func flushNow() {
        debounceTask?.cancel()
        debounceTask = nil
        guard state.isDirty else { return }
        
        syncNow(.background)
    }
    
    func awaitFirstSyncIfLocalEmpty(timeout: TimeInterval) async {
        guard let userID = AuthManager.shared.userID else { return }
        wipeOnAccountSwitchIfNeeded(currentUserID: userID)
        
        guard !isFrozenForNewerSchema,
              state.lastSyncedServerUpdatedAt == nil,
              !hasAnyLocalProgress() else { return }
        
        syncNow(.signIn)
        guard let task = syncTask else { return }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await task.value }
            group.addTask { try? await Task.sleep(for: .seconds(timeout)) }
            
            await group.next()
            group.cancelAll()
        }
    }
    
    func handleSignedOut() {
        passGeneration += 1
        syncTask?.cancel()
        syncTask = nil
        rerunRequested = false
        isSyncing = false
        debounceTask?.cancel()
        debounceTask = nil
        retryTask?.cancel()
        retryTask = nil
    }
    
    // MARK: - Pass
    private func runSyncPass(_ trigger: SyncTrigger) async {
        guard let userID = AuthManager.shared.userID else { return }
        
        wipeOnAccountSwitchIfNeeded(currentUserID: userID)
        
        if state.lastSyncedUserID == nil, !state.isDirty, hasAnyLocalProgress() {
            state.noteLocalChange()
        }
        
        let localDirty = state.isDirty
        let serverToken: String?
        
        do {
            serverToken = try await service.fetchUpdatedAt(userID: userID)
        } catch {
            handleFailure()
            return
        }
        
        guard !Task.isCancelled, AuthManager.shared.userID == userID else { return }
        
        let serverChanged = serverToken != state.lastSyncedServerUpdatedAt
        
        switch (localDirty, serverChanged) {
        case (false, false):
            completePass()
        case (true, false):
            await push(userID: userID)
        case (false, true):
            if let serverToken {
                await pull(userID: userID, expectedToken: serverToken)
            } else if hasAnyLocalProgress() {
                state.noteLocalChange()
                await push(userID: userID)
            } else {
                state.clearServerToken()
                completePass()
            }
        case (true, true):
            if let serverToken, isServerNewer(serverToken: serverToken) {
                await pull(userID: userID, expectedToken: serverToken)
            } else {
                await push(userID: userID)
            }
        }
        
        if state.isDirty {
            scheduleDebouncedPush()
        }
    }
    
    private func push(userID: UUID) async {
        let capturedChangeCount = state.localChangeCount
        let snapshot = buildSnapshot()
        let progressPercent = Int(QuizRepository.shared.catalog.progress * 100)
        let scores = ScoreManager.shared.total
        let serverToken: String
        
        do {
            serverToken = try await service.push(
                userID: userID,
                snapshot: snapshot,
                progressPercent: progressPercent,
                scores: scores,
                clientUpdatedAt: Date()
            )
        } catch {
            handleFailure()
            return
        }
        
        guard AuthManager.shared.userID == userID else { return }
        state.markSynced(
            changeCount: capturedChangeCount,
            serverUpdatedAt: serverToken,
            userID: userID
        )
        completePass()
    }
    
    private func pull(userID: UUID, expectedToken: String) async {
        let server: ServerProgress?
        
        do {
            server = try await service.fetchSnapshot(userID: userID)
        } catch {
            handleFailure()
            return
        }
        
        guard !Task.isCancelled, authManager.userID == userID else { return }
        guard let server else { return }
        
        switch server.payload {
        case .newerSchema:
            isFrozenForNewerSchema = true
        case .corrupt:
            if state.isDirty {
                await push(userID: userID)
            }
        case .snapshot(let snapshot):
            applySnapshot(snapshot, serverScores: server.scores)
            state.markSynced(
                changeCount: state.localChangeCount,
                serverUpdatedAt: server.updatedAt,
                userID: userID
            )
            
            completePass()
            _ = expectedToken
        }
    }
    
    // MARK: - Local Store Operations
    func wipeForAccountDeletion() {
        handleSignedOut()
        stack.isSyncSuppressed = true
        
        wipeAllProgress()
        ScoreManager.shared.reset()
        stack.isSyncSuppressed = false
        
        QuizRepository.shared.rehydrate()
        
        restoreCount += 1
        
        isFrozenForNewerSchema = false
        state.clearAll()
    }
    
    func clearProgress() {
        wipeAllProgress()
        QuizRepository.shared.rehydrate()
        restoreCount += 1
        state.noteLocalChange()
        flushNow()
    }
    
    private func buildSnapshot() -> ProgressSnapshot {
        ProgressSnapshot(
            schemaVersion: ProgressSnapshot.currentSchemaVersion,
            answers: AnswerStorage.shared.snapshotAnswers(),
            mistakePool: AnswerStorage.shared.fetchGlobalWrongIDs(),
            topicStats: TopicStatsStorage.shared.snapshotItems(),
            savedWords: SavedWordsStore.shared.snapshotItems(),
            folders: SavedQuestionsStore.shared.snapshotFolders(),
            savedQuestions: SavedQuestionsStore.shared.snapshotSavedQuestions()
        )
    }
    
    private func applySnapshot(_ snapshot: ProgressSnapshot, serverScores: Int?) {
        stack.isSyncSuppressed = true
        wipeAllProgress()
        
        AnswerStorage.shared.restore(
            answers: snapshot.answers,
            mistakeIDs: snapshot.mistakePool
        )
        
        TopicStatsStorage.shared.restore(snapshot.topicStats)
        SavedWordsStore.shared.restore(snapshot.savedWords)
        
        SavedQuestionsStore.shared.restore(
            folders: snapshot.folders,
            savedQuestions: snapshot.savedQuestions
        )
        
        if let serverScores {
            ScoreManager.shared.applyServer(total: serverScores)
        }
        
        stack.saveContext()
        stack.isSyncSuppressed = false
        QuizRepository.shared.rehydrate()
        restoreCount += 1
    }
    
    private func wipeOnAccountSwitchIfNeeded(currentUserID: UUID) {
        guard let lastUserID = state.lastSyncedUserID else {
            state.claimUser(currentUserID)
            return
        }
        
        guard lastUserID != currentUserID.uuidString else { return }
        stack.isSyncSuppressed = true
        wipeAllProgress()
        ScoreManager.shared.reset()
        
        stack.isSyncSuppressed = false
        QuizRepository.shared.rehydrate()
        
        restoreCount += 1
        
        isFrozenForNewerSchema = false
        state.resetForAccountSwitch(to: currentUserID)
    }
    
    private func wipeAllProgress() {
        AnswerStorage.shared.removeAll()
        TopicStatsStorage.shared.removeAll()
        SavedWordsStore.shared.removeAll()
        SavedQuestionsStore.shared.removeAll()
    }
    
    private func hasAnyLocalProgress() -> Bool {
        progressEntityNames.contains { stack.hasAnyRows(entityName: $0) }
    }
    
    // MARK: - Outcome Handling
    private func isServerNewer(serverToken: String) -> Bool {
        guard let serverDate = PostgresTimestamp.date(from: serverToken) else {
            return false
        }
        
        guard let localDate = state.lastLocalChangeAt else { return true }
        
        return serverDate > localDate
    }
    
    private func completePass() {
        lastPassCompletedAt = Date()
        failureCount = 0
    }
    
    private func handleFailure() {
        failureCount += 1
        guard failureCount <= maxRetries, NetworkMonitor.shared.isConnected else {
            return
        }
        
        let delay = pow(3.0, Double(failureCount))
        
        retryTask = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            syncNow(.retry)
        }
    }
}
