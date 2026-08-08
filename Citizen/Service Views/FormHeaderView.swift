//
//  FormHeaderView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct FormHeaderView: View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        header
    }
}

// MARK: - Builder
extension FormHeaderView {
    private var header: some View {
        Text(text)
            .foregroundStyle(Color.citizen.secondaryText)
            .font(.caption)
            .fontDesign(.rounded)
            .tracking(1)
            .textCase(.uppercase)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 6)
    }
}
