//
//  AnswerResultBanner.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AnswerResultBanner: View {
    private let isCorrect: Bool
    private let title: String
    private let message: String
    
    init(isCorrect: Bool, title: String, message: String) {
        self.isCorrect = isCorrect
        self.title = title
        self.message = message
    }
    
    var body: some View {
        banner
    }
}

// MARK: - Builder
extension AnswerResultBanner {
    private var banner: some View {
        VStack {
            Spacer()
            HStack {
                Image.system.checkmarkAndXmark(isCorrect)
                    .foregroundStyle(isCorrect ? Gradient.green : Gradient.red)
                    .font(.title)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundStyle(Color.citizen.mainText)
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
                    Text(message)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .minimumScaleFactor(0.6)
            }
            .padding()
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
                .foregroundStyle(Color.citizen.groupBackground)
                .ignoresSafeArea()
                .shadow(color: Color.citizen.viewShadow, radius: 2)
            }
        }
    }
}
