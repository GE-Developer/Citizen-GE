//
//  HomeView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct HomeView: View {
    @StateObject private var store = StoreManager()
    
    @State private var tabBarState = TabBarState()
    @State private var languageManager = LanguageManager.shared
    @State private var grants = GrantManager.shared
    @State private var entitlements = EntitlementManager.shared
    
    private var layoutDirection: LayoutDirection {
        let rtlLanguages = Language.rtlLanguages
        return rtlLanguages.contains(languageManager.currentLanguageID)
        ? .rightToLeft
        : .leftToRight
    }
    
    private let accent = AccentColorManager.shared
    private let screenshotProtector = ScreenshotManager.shared
    
    var body: some View {
        homeView
            .safeAreaInset(edge: .bottom) {
                CustomTabBar()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .task(id: store.didLoadCustomerInfo) { setAccentColorIfPremiumExpired() }
            .task(id: store.didLoadCustomerInfo) { await setIconIfPremiumExpired() }
            .task(id: store.isPremium) { syncCaptureProtection() }
            .task(id: grants.hasGrant) { store.applyGrant(grants.hasGrant) }
            .task(id: entitlements.isPremium) { store.applyServerPremium(entitlements.isPremium) }
            .environment(\.layoutDirection, layoutDirection)
            .environment(tabBarState)
            .environment(languageManager)
            .environmentObject(store)
    }
}

// MARK: - Builder
extension HomeView {
    private var homeView: some View {
        TabView(selection: $tabBarState.selectedTab) {
            dictionary
            home
            settings
        }
    }
    
    private var dictionary: some View {
        NavigationStack {
            DictionaryView()
        }
        .environment(\.parentTab, .dictionary)
        .toolbar(.hidden, for: .tabBar)
        .tag(RootTab.dictionary)
    }
    
    private var home: some View {
        NavigationStack {
            MainView()
        }
        .environment(\.parentTab, .home)
        .toolbar(.hidden, for: .tabBar)
        .tag(RootTab.home)
    }
    
    private var settings: some View {
        NavigationStack {
            SettingsView()
        }
        .environment(\.parentTab, .settings)
        .toolbar(.hidden, for: .tabBar)
        .tag(RootTab.settings)
    }
}

// MARK: - Logic
extension HomeView {
    private func setAccentColorIfPremiumExpired() {
        guard store.didLoadCustomerInfo, !store.isPremium else { return }
        if accent.currentColor != .georgian {
            accent.currentColor = .georgian
        }
    }
    
    private func setIconIfPremiumExpired() async {
        guard store.didLoadCustomerInfo, !store.isPremium else { return }
        if AppIconManager.currentIcon() != .georgianBlack {
            do {
                try await Task.sleep(for: .milliseconds(600))
                try await AppIconManager.setIcon(.georgianBlack)
            } catch {
                return
            }
        }
    }
    
    private func syncCaptureProtection() {
        screenshotProtector.isScreenshotProtectionOn = !store.isPremium
    }
}
