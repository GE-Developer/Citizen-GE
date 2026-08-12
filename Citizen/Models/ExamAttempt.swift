//
//  ExamAttempt.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

// MARK: - ExamAttemptKind
enum ExamAttemptKind: String {
    case fullSummary
    case fullSection
    case single
}

// MARK: - ExamAttempt
struct ExamAttempt: Identifiable, Hashable {
    var mistakeCount: Int {
        total - correct
    }
    
    var id: String {
        "\(attemptID.uuidString)#\(kind.rawValue)#\(categoryID ?? "")"
    }
    
    let attemptID: UUID
    let kind: ExamAttemptKind
    let categoryID: String?
    let date: Date
    let correct: Int
    let total: Int
    let isPassed: Bool
    let wrongQuestionIDs: [String]
}

// MARK: - ExamAttemptGroup
struct ExamAttemptGroup: Identifiable {
    var mistakeCount: Int {
        total - correct
    }
    
    var id: UUID {
        attemptID
    }
    
    let attemptID: UUID
    let date: Date
    let isFull: Bool
    let categoryID: String?
    let correct: Int
    let total: Int
    let isPassed: Bool
    let sections: [ExamAttempt]
    let wrongQuestionIDs: [String]
}

// MARK: - Grouping
extension ExamAttempt {
    static func groups(from attempts: [ExamAttempt]) -> [ExamAttemptGroup] {
        var order: [UUID] = []
        var rows: [UUID: [ExamAttempt]] = [:]
        
        for attempt in attempts {
            if rows[attempt.attemptID] == nil {
                order.append(attempt.attemptID)
            }
            rows[attempt.attemptID, default: []].append(attempt)
        }
        
        return order.compactMap { attemptID in
            rows[attemptID].flatMap(makeGroup)
        }
    }
    
    private static func makeGroup(from rows: [ExamAttempt]) -> ExamAttemptGroup? {
        let sections = rows.filter { $0.kind != .fullSummary }
        
        guard let head = rows.first(where: { $0.kind == .fullSummary }) ?? sections.first else {
            return nil
        }
        
        return ExamAttemptGroup(
            attemptID: head.attemptID,
            date: head.date,
            isFull: head.kind == .fullSummary,
            categoryID: head.categoryID,
            correct: head.correct,
            total: head.total,
            isPassed: head.isPassed,
            sections: head.kind == .fullSummary ? sections : [],
            wrongQuestionIDs: sections.flatMap(\.wrongQuestionIDs)
        )
    }
}

// MARK: - Building From Session
extension ExamAttempt {
    static func attempts(from session: ExamSession, date: Date = Date()) -> [ExamAttempt] {
        let attemptID = UUID()
        
        let sectionKind: ExamAttemptKind
        switch session.mode {
        case .full:
            sectionKind = .fullSection
        case .single:
            sectionKind = .single
        }
        
        let sectionAttempts = session.sections.map { section in
            ExamAttempt(
                attemptID: attemptID,
                kind: sectionKind,
                categoryID: section.categoryID,
                date: date,
                correct: section.correctCount,
                total: section.totalCount,
                isPassed: section.isPassed,
                wrongQuestionIDs: section.wrongAnsweredQuestionIDs
            )
        }
        
        guard case .full = session.mode else { return sectionAttempts }
        
        let summary = ExamAttempt(
            attemptID: attemptID,
            kind: .fullSummary,
            categoryID: nil,
            date: date,
            correct: session.correctTotal,
            total: session.questionTotal,
            isPassed: session.isPassed,
            wrongQuestionIDs: []
        )
        
        return [summary] + sectionAttempts
    }
}
