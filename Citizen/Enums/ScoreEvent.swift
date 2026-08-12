//
//  ScoreEvent.swift
//  Citizen
//
//  Created by GE-Developer
//

enum ScoreEvent: Sendable {
    case solvedFirstTime
    case solvedAgain
    case forgotten
    case practiceSolved
    case mistakeFixed
    case topicCompleted
    case examPassed
    case examFailed
    case sectionExamPassed
    case sectionExamFailed
    
    var points: Int {
        switch self {
        case .solvedFirstTime:
            return 1
        case .solvedAgain:
            return 1
        case .forgotten:
            return -5
        case .practiceSolved:
            return 1
        case .mistakeFixed:
            return 1
        case .topicCompleted:
            return 3
        case .examPassed:
            return 10
        case .examFailed:
            return -10
        case .sectionExamPassed:
            return 3
        case .sectionExamFailed:
            return -10
        }
    }
}
