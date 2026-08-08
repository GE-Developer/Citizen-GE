//
//  QuestionTextCard.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuestionTextCard: View {
    private let text: String
    private let isVoicing: Bool
    
    init(text: String, isVoicing: Bool = false) {
        self.text = text
        self.isVoicing = isVoicing
    }
    
    var body: some View {
        questionTextCard
    }
}

// MARK: - Builder
extension QuestionTextCard {
    private var questionTextCard: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title3)
            .fontWeight(.regular)
            .fontDesign(.rounded)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.citizen.mainText)
            .voiceHighlight(isActive: isVoicing)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
    }
}
