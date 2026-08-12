//
//  ProgressSnapshot.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct ProgressSnapshot: Codable, Sendable, Equatable {
    struct AnsweredQuestion: Codable, Sendable, Equatable {
        let id: String
        let isCorrect: Bool
    }
    
    struct TopicStatsItem: Codable, Sendable, Equatable {
        let topicID: String
        let attempts: Int
        let bestStreak: Int
        let successfulCompletions: Int
        let currentRoundSize: Int
        let visitedInRound: Int
    }
    
    struct SavedWordItem: Codable, Sendable, Equatable {
        let word: String
        let createdAt: Double
    }
    
    struct FolderItem: Codable, Sendable, Equatable {
        let id: String
        let name: String
        let createdAt: Double
    }
    
    struct SavedQuestionItem: Codable, Sendable, Equatable {
        let questionID: String
        let folderID: String
        let createdAt: Double
    }
    
    struct ExamAttemptItem: Codable, Sendable, Equatable {
        let attemptID: String
        let kind: String
        let categoryID: String?
        let date: Double
        let correct: Int
        let total: Int
        let isPassed: Bool
        let wrongQuestionIDs: [String]?
    }
    
    enum CodingKeys: String, CodingKey {
        case schemaVersion, answers, mistakePool, topicStats
        case savedWords, folders, savedQuestions, examAttempts
    }
    
    var isEmpty: Bool {
        answers.isEmpty
        && mistakePool.isEmpty
        && topicStats.isEmpty
        && savedWords.isEmpty
        && folders.isEmpty
        && savedQuestions.isEmpty
        && examAttempts.isEmpty
    }
    
    let schemaVersion: Int
    
    let answers: [AnsweredQuestion]
    let mistakePool: [String]
    let topicStats: [TopicStatsItem]
    let savedWords: [SavedWordItem]
    let folders: [FolderItem]
    let savedQuestions: [SavedQuestionItem]
    let examAttempts: [ExamAttemptItem]
    
    static let currentSchemaVersion = 1
}

// MARK: - Decodable
extension ProgressSnapshot {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        answers = try container.decode([AnsweredQuestion].self, forKey: .answers)
        mistakePool = try container.decode([String].self, forKey: .mistakePool)
        topicStats = try container.decode([TopicStatsItem].self, forKey: .topicStats)
        savedWords = try container.decode([SavedWordItem].self, forKey: .savedWords)
        folders = try container.decode([FolderItem].self, forKey: .folders)
        savedQuestions = try container.decode([SavedQuestionItem].self, forKey: .savedQuestions)
        examAttempts = try container.decodeIfPresent([ExamAttemptItem].self, forKey: .examAttempts) ?? []
    }
}
