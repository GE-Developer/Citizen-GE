//
//  CustomTabBar.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomTabBar: View {
    @Environment(TabBarState.self) private var tabBarState
    
    private let haptics = HapticsManager.shared
    
    private static let hideSystemTabBar: Void = {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }()
    
    init() {
        _ = Self.hideSystemTabBar
    }
    
    var body: some View {
        customTabBar
    }
}

// MARK: - Builder
extension CustomTabBar {
    private var customTabBar: some View {
        HStack(spacing: 7) {
            let tabs = RootTab.allCases
            
            ForEach(tabs) { tab in
                icon(for: tab)
                divider(after: tab, in: tabs)
            }
        }
        .padding(.horizontal, 15)
        .frame(height: tabBarState.height)
        .background(background)
        .overlay(overlayStroke)
        .padding(.horizontal, 32)
        .padding(.bottom, isFaceIDPhone ? -10 : 15)
        .background {
            LinearGradient(
                colors: [
                    Color.citizen.background,
                    Color.citizen.background.opacity(0.7),
                    Color.clear
                ],
                startPoint: .bottom, endPoint: .top
            )
            .ignoresSafeArea()
        }
        .offset(y: tabBarState.isVisible ? 0 : tabBarState.height)
        .opacity(tabBarState.isVisible ? 1 : 0)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: tabBarState.isVisible
        )
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundStyle(Color.citizen.groupBackground)
            .shadow(color: Color.citizen.navBarShadow, radius: 2)
    }
    
    private var overlayStroke: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.citizen.background.opacity(0.7), lineWidth: 0.1)
    }
    
    private func icon(for tab: RootTab) -> some View {
        Group {
            switch tab {
            case .dictionary:
                Image.system.dictionary
            case .home:
                Image.system.books
            case .settings:
                Image.system.gear
                    .rotationEffect(.degrees(tab == tabBarState.selectedTab ? 120 : 0))
                    .fontWeight(tab == tabBarState.selectedTab ? .bold : .regular)
            }
        }
        .font(.title2)
        .foregroundStyle(
            tabBarState.selectedTab == tab
            ? Color.citizen.accent
            : Color.citizen.grayDark
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .animation(.bouncy, value: tabBarState.selectedTab)
        .onTapGesture { tapGesture(on: tab) }
    }
    
    @ViewBuilder
    private func divider(after tab: RootTab, in tabs: [RootTab]) -> some View {
        if tab != tabs.last {
            Divider()
                .padding(.vertical, 20)
                .foregroundStyle(Color.citizen.grayLight)
        }
    }
}

// MARK: - Logic
extension CustomTabBar {
    private func tapGesture(on tab: RootTab) {
        guard tabBarState.selectedTab != tab else { return }
        withAnimation(.easeIn.speed(4)) {
            tabBarState.selectedTab = tab
        }
        haptics.selectionChanged()
    }
}
