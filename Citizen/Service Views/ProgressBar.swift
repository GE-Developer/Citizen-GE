//
//  ProgressBar.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ProgressBar: View {
    private let styles: [AnyShapeStyle]
    
    init(questions: [Question], currentQuestionID: String? = nil) {
        self.styles = questions.map {
            Self.style(for: $0, currentQuestionID: currentQuestionID)
        }
    }
    
    init(topics: [Topic]) {
        self.styles = topics.map { Self.style(for: $0.phase) }
    }
    
    var body: some View {
        bar
    }
}

// MARK: - Builder
extension ProgressBar {
    private var bar: some View {
        HStack(spacing: 3) {
            ForEach(styles.indices, id: \.self) { index in
                Capsule()
                    .fill(styles[index])
                    .frame(height: 6)
            }
        }
    }
}

// MARK: - Logic
extension ProgressBar {
    private static func style(
        for question: Question,
        currentQuestionID: String?
    ) -> AnyShapeStyle {
        if question.id == currentQuestionID {
            return AnyShapeStyle(Color.citizen.white)
        }
        
        switch question.status {
        case .correct:
            return AnyShapeStyle(Gradient.green)
        case .wrong:
            return AnyShapeStyle(Gradient.red)
        case .unanswered:
            return AnyShapeStyle(Color.citizen.background)
        }
    }
    
    private static func style(for phase: TopicPhase) -> AnyShapeStyle {
        switch phase {
        case .completed:
            AnyShapeStyle(Gradient.green)
        case .workingOnMistakes:
            AnyShapeStyle(Gradient.red)
        case .notStarted, .inProgress:
            AnyShapeStyle(Color.citizen.background)
        }
    }
}
