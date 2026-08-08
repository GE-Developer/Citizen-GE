//
//  QuestionProgressHeader.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuestionProgressHeader: View {
    private let counterText: String
    private let questions: [Question]
    private let currentQuestionID: String?
    
    init(counterText: String, questions: [Question], currentQuestionID: String?) {
        self.counterText = counterText
        self.questions = questions
        self.currentQuestionID = currentQuestionID
    }
    
    var body: some View {
        progressRow
    }
}

// MARK: - Builder
extension QuestionProgressHeader {
    private var progressRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(counterText.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundStyle(Color.citizen.secondaryText)
            ProgressBar(
                questions: questions,
                currentQuestionID: currentQuestionID
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
