//
//  CountHeaderView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CountHeaderView: View {
    private let count: String
    private let suffix: String
    
    init(count: String, suffix: String) {
        self.count = count
        self.suffix = suffix
    }
    
    var body: some View {
        countHeader
    }
}

// MARK: - Builder
extension CountHeaderView {
    private var countHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(count)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Gradient.accent)
            
            Text(suffix.lowercased())
                .font(.headline)
                .fontWeight(.regular)
                .foregroundStyle(Color.citizen.secondaryText)
            
            Spacer()
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}
