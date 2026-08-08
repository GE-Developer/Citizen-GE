//
//  CustomForm.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomForm<Content: View, HeaderContent: View>: View {
    private let headerText: String?
    private let headerContent: HeaderContent
    private let content: Content
    
    init(
        headerText: String? = nil,
        @ViewBuilder headerContent: () -> HeaderContent = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.headerText = headerText
        self.headerContent = headerContent()
        self.content = content()
    }
    
    var body: some View {
        customForm
    }
}

// MARK: - Builder
extension CustomForm {
    private var customForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let headerText {
                HStack(spacing: 0) {
                    FormHeaderView(headerText)
                    Spacer()
                    headerContent
                }
            }
            VStack(spacing: 0) {
                content
            }
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
