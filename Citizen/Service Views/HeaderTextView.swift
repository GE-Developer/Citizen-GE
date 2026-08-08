//
//  HeaderTextView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct HeaderTextView: View {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        headerTextView
    }
}

// MARK: - Builder
extension HeaderTextView {
    private var headerTextView: some View {
        HStack() {
            Text(text.asMarkdown)
                .font(.subheadline)
                .fontWeight(.thin)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(10)
        .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundStyle(Color.citizen.secondaryGroupBackground)
    }
}
