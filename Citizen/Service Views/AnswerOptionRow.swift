//
//  AnswerOptionRow.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AnswerOptionRow: View {
    private let answer: Answer
    private let state: AnswerRowState
    private let showsLabel: Bool
    private let revealed: Bool
    
    init(answer: Answer, state: AnswerRowState, showsLabel: Bool, revealed: Bool) {
        self.answer = answer
        self.state = state
        self.showsLabel = showsLabel
        self.revealed = revealed
    }
    
    var body: some View {
        answerRow
    }
}

// MARK: - Builder
extension AnswerOptionRow {
    private var answerRow: some View {
        HStack(spacing: 12) {
            if showsLabel {
                Text(answer.label)
                    .font(.title3)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundStyle(Gradient.accent)
                    .frame(width: 18, alignment: .leading)
            }
            
            Text(answer.text)
                .fontDesign(.rounded)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            Image.system.checkmarkAndXmark(answer.isCorrect)
                .fontWeight(.semibold)
                .foregroundStyle(answer.isCorrect ? Gradient.green : Gradient.red)
                .opacity(checkmarkOpacity)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(background)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(strokeStyle, lineWidth: strokeWidth)
            }
        }
        .animation(.smooth, value: revealed)
    }
}

// MARK: - Logic
extension AnswerOptionRow {
    private var background: AnyShapeStyle {
        switch state {
        case .correct, .revealCorrect:
            AnyShapeStyle(Gradient.green.opacity(0.18))
        case .wrong:
            AnyShapeStyle(Gradient.red.opacity(0.18))
        case .idle, .selected:
            AnyShapeStyle(Gradient.neutral)
        }
    }
    
    private var strokeStyle: AnyShapeStyle {
        switch state {
        case .correct, .revealCorrect:
            AnyShapeStyle(Gradient.green)
        case .wrong:
            AnyShapeStyle(Gradient.red)
        case .idle, .selected:
            AnyShapeStyle(Color.citizen.blackAndWhite)
        }
    }
    
    private var strokeWidth: CGFloat {
        switch state {
        case .selected:
            2
        case .correct, .revealCorrect, .wrong:
            1.5
        case .idle:
            0
        }
    }
    
    private var checkmarkOpacity: Double {
        switch state {
        case .correct, .wrong, .revealCorrect:
            1
        case .idle, .selected:
            0
        }
    }
}
