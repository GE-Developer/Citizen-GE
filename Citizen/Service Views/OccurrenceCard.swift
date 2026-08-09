//
//  OccurrenceCard.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct OccurrenceCard: View {
    private let row: OccurrenceRow
    private let action: () -> Void
    
    init(row: OccurrenceRow, action: @escaping () -> Void) {
        self.row = row
        self.action = action
    }
    
    var body: some View {
        card
    }
}

// MARK: - Builder
extension OccurrenceCard {
    private var card: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                cardHeader
                questionText
                if row.hasSentence {
                    sentence
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    private var cardHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Badge(row.number)
                Spacer()
                Image.system.chevron
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            Text(row.categoryName)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Gradient.accent)
            
            Text(row.topicName)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Gradient.accent)
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    private var questionText: some View {
        HStack(spacing: 12) {
            if let imageUrl = row.imageUrl {
                thumbnail(imageUrl)
            }
            
            Text(row.questionText)
                .font(.subheadline)
                .fontWeight(.regular)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func thumbnail(_ name: String) -> some View {
        MediaImageView(
            kind: .questionImage,
            name: name,
            sizing: .thumbnail(side: 64)
        )
    }
    
    private var sentence: some View {
        HStack(spacing: 10) {
            Capsule()
                .frame(width: 2)
                .foregroundStyle(Gradient.accent)
            RichTextView(segments: row.sentenceSegments, lineLimit: 3)
                .font(.subheadline)
                .fontWeight(.regular)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}
