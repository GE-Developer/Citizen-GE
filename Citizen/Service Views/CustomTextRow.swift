//
//  CustomTextRow.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomTextRow: View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(text.asMarkdown)
                .foregroundStyle(Color.citizen.secondaryText)
                .font(.subheadline)
                .fontWeight(.light)
                .fontDesign(.rounded)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .padding(.vertical, 10)
            Spacer()
        }
    }
}
