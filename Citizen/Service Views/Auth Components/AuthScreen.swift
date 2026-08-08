//
//  AuthScreen.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthScreen<TopBar: View, Content: View, BottomBar: View>: View {
    private let topBar: TopBar
    private let content: Content
    private let bottomBar: BottomBar
    private let doneTitle: String
    
    private var minContentHeight: CGFloat {
        screenHeight - safeAreaTop - safeAreaBottom
    }
    
    init(
        doneTitle: String = L10n("Keyboard.done"),
        @ViewBuilder topBar: () -> TopBar = { EmptyView() },
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomBar: () -> BottomBar
    ) {
        self.doneTitle = doneTitle
        self.topBar = topBar()
        self.content = content()
        self.bottomBar = bottomBar()
    }
    
    var body: some View {
        authScreen
    }
}

// MARK: - Builder
extension AuthScreen {
    private var authScreen: some View {
        ScrollView {
            VStack {
                topBar
                    .padding(.bottom, 10)
                content
                Spacer()
                bottomBar
            }
            .padding(.top, 8)
            .padding(.bottom, isFaceIDPhone ? -5 : 16)
            .frame(minHeight: minContentHeight)
        }
        .safeAreaPadding(.horizontal)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .toolbar { keyboardToolbar }
    }
    
    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button(doneTitle, action: dismissKeyboard)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.accent)
        }
    }
}
