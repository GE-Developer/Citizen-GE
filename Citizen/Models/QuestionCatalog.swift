//
//  QuestionCatalog.swift
//  Citizen
//
//  Created by GE-Developer
//

// MARK: - QuestionCatalog
struct QuestionCatalog: Decodable, Hashable {
    var categories: [Category]
    
    var totalTopics: Int {
        categories
            .reduce(0) { $0 + $1.totalTopics }
    }
    
    var completedTopics: Int {
        categories
            .reduce(0) { $0 + $1.completedTopics }
    }
    
    var totalQuestions: Int {
        categories
            .reduce(0) { $0 + $1.totalQuestions }
    }
    
    var correctCount: Int {
        categories
            .reduce(0) { $0 + $1.correctCount }
    }
    
    var wrongCount: Int {
        categories
            .reduce(0) { $0 + $1.wrongCount }
    }
    
    var progress: Double {
        Double(correctCount) / Double(max(totalQuestions, 1))
    }
    
    var mistakePoolQuestions: [Question] {
        questions(where: \.isInMistakePool)
    }
    
    var mistakePoolCount: Int {
        countQuestions(where: \.isInMistakePool)
    }
    
    var correctPoolQuestions: [Question] {
        questions { $0.status == .correct && !$0.isInMistakePool }
    }
    
    var correctPoolCount: Int {
        countQuestions { $0.status == .correct && !$0.isInMistakePool }
    }
    
    private func questions(where isIncluded: (Question) -> Bool) -> [Question] {
        var result: [Question] = []
        for category in categories {
            for topic in category.topics {
                for question in topic.questions where isIncluded(question) {
                    result.append(question)
                }
            }
        }
        return result
    }
    
    private func countQuestions(where isIncluded: (Question) -> Bool) -> Int {
        var count = 0
        for category in categories {
            for topic in category.topics {
                count += topic.questions.count(where: isIncluded)
            }
        }
        return count
    }
}

// MARK: - Category
struct Category: Decodable, Hashable, Identifiable {
    let id: String
    let index: Int
    let name: String
    let description: String?
    let imageUrl: String?
    
    var topics: [Topic]
    
    var totalTopics: Int {
        topics.count
    }
    
    var totalQuestions: Int {
        topics
            .reduce(0) { $0 + $1.totalCount }
    }
    
    var correctCount: Int {
        topics
            .reduce(0) { $0 + $1.correctCount }
    }
    
    var wrongCount: Int {
        topics
            .reduce(0) { $0 + $1.wrongCount }
    }
    
    var completedTopics: Int {
        topics
            .lazy
            .filter { $0.phase == .completed }
            .count
    }
    
    var progress: Double {
        Double(correctCount) / Double(max(totalQuestions, 1))
    }
}

// MARK: - Topic
struct Topic: Decodable, Hashable, Identifiable {
    let id: String
    let index: Int
    let name: String
    let description: String?
    let isPremium: Bool
    let imageUrl: String?
    
    var questions: [Question]
    
    var totalCount: Int {
        questions.count
    }
    
    var correctCount: Int {
        questions
            .lazy
            .filter { $0.status == .correct }
            .count
    }
    
    var wrongCount: Int {
        questions
            .lazy
            .filter { $0.status == .wrong }
            .count
    }
    
    var answeredCount: Int {
        questions.count { $0.status != .unanswered }
    }
    
    var progress: Double {
        Double(correctCount) / Double(max(totalCount, 1))
    }
    
    var phase: TopicPhase {
        var answered = 0
        var wrong = 0
        
        for question in questions {
            switch question.status {
            case .unanswered:
                continue
            case .correct:
                answered += 1
            case .wrong:
                answered += 1
                wrong += 1
            }
        }
        
        guard answered > 0 else { return .notStarted }
        if answered < questions.count { return .inProgress }
        
        return wrong == 0 ? .completed : .workingOnMistakes
    }
}

// MARK: - Question
struct Question: Decodable, Hashable, Identifiable {
    let id: String
    let number: String
    let index: Int
    let question: String
    let audioUrl: String?
    let additionalText: String?
    let additionalAudioUrl: String?
    let explanations: [String]
    let imageUrl: String?
    let answers: [Answer]
    
    var status: AnswerStatus = .unanswered
    var isInMistakePool: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, number, index, question, audioUrl
        case additionalText, additionalAudioUrl, explanations, imageUrl, answers
    }
}

// MARK: - Answer
struct Answer: Decodable, Hashable, Identifiable {
    let label: String
    let text: String
    let audioUrl: String?
    let imageUrl: String?
    let isCorrect: Bool
    
    var id: String {
        text
    }
}
