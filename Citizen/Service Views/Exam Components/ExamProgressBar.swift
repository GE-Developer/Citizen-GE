//
//  ExamProgressBar.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamProgressBar: View {
    private let counterText: String
    private let answeredFlags: [Bool]
    private let currentIndex: Int
    
    init(counterText: String, answeredFlags: [Bool], currentIndex: Int) {
        self.counterText = counterText
        self.answeredFlags = answeredFlags
        self.currentIndex = currentIndex
    }
    
    var body: some View {
        progressRow
    }
}

// MARK: - Builder
extension ExamProgressBar {
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
            
            segments
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var segments: some View {
        HStack(spacing: 4) {
            ForEach(Array(answeredFlags.enumerated()), id: \.offset) { index, isAnswered in
                Capsule()
                    .fill(
                        isAnswered
                        ? AnyShapeStyle(Gradient.accent)
                        : AnyShapeStyle(Color.citizen.darkGroupBackground)
                    )
                    .frame(height: 6)
                    .overlay {
                        if index == currentIndex {
                            Capsule()
                                .strokeBorder(Color.citizen.mainText.opacity(0.7), lineWidth: 1.5)
                        }
                    }
            }
        }
        .animation(.smooth, value: currentIndex)
        .animation(.smooth, value: answeredFlags)
    }
}
