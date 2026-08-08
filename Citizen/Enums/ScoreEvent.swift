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
    
    var points: Int {
        switch self {
        case .solvedFirstTime:
            return ScoreWeights.solvedFirstTime
        case .solvedAgain:
            return ScoreWeights.solvedAgain
        case .forgotten:
            return ScoreWeights.forgotten
        case .practiceSolved:
            return ScoreWeights.practiceSolved
        case .mistakeFixed:
            return ScoreWeights.mistakeFixed
        case .topicCompleted:
            return ScoreWeights.topicCompleted
        case .examPassed:
            return ScoreWeights.examPassed
        }
    }
}
