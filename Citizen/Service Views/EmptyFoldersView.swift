//
//  EmptyFoldersView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct EmptyFoldersView: View {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        emptyFolders
    }
}

// MARK: - Builder
extension EmptyFoldersView {
    private var emptyFolders: some View {
        VStack(spacing: 10) {
            Image.system.folder
                .font(.system(size: 24))
                .foregroundStyle(Color.citizen.secondaryText)
                .frame(width: 55, height: 55)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.citizen.groupBackground)
                }
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
        }
        .frame(maxWidth: .infinity)
    }
}
