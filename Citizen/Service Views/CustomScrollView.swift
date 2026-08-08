//
//  CustomScrollView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomScrollView<Content: View, NavBarItems: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.parentTab) private var parentTab
    @Environment(TabBarState.self) private var tabBarState
    
    @State private var navState = NavBarState()
    @State private var isRefreshing = false
    @State private var pulledEnough = false
    
    private let title: String
    private let subTitle: String?
    private let alignment: HorizontalAlignment
    private let withBackButton: Bool
    private let tabBarIsVisible: Bool
    private let showNavBar: Bool
    private let onRefresh: (() async -> Void)?
    
    private let pullDistance: CGFloat = 90
    private let refreshBandHeight: CGFloat = 52
    private let minSpinnerDuration: TimeInterval = 0.6
    
    @ViewBuilder private let navBarItems: () -> NavBarItems
    @ViewBuilder private let content: (ScrollViewProxy) -> Content
    
    init(
        title: String,
        subTitle: String? = nil,
        alignment: HorizontalAlignment = .leading,
        withBackButton: Bool = true,
        tabBarIsVisible: Bool = false,
        onRefresh: (() async -> Void)? = nil,
        @ViewBuilder navBarItems: @escaping () -> NavBarItems,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> Content
    ) {
        self.title = title
        self.subTitle = subTitle
        self.alignment = alignment
        self.withBackButton = withBackButton
        self.tabBarIsVisible = tabBarIsVisible
        self.showNavBar = true
        self.onRefresh = onRefresh
        self.navBarItems = navBarItems
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            background.zIndex(0)
            scroll.zIndex(1)
            if showNavBar {
                NavigationBarView(
                    navState: navState,
                    title: title,
                    subTitle: subTitle,
                    alignment: alignment,
                    withBackButton: withBackButton,
                    onBack: { dismiss() },
                    navBarItems: navBarItems
                )
                .zIndex(2)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !tabBarIsVisible {
                tabBarState.enterStack(for: parentTab)
            }
            closeKeyboard()
        }
        .onDisappear {
            if !tabBarIsVisible {
                tabBarState.exitStack(for: parentTab)
            }
        }
    }
}

extension CustomScrollView where NavBarItems == EmptyView {
    init(
        tabBarIsVisible: Bool = false,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> Content
    ) {
        self.title = ""
        self.subTitle = nil
        self.alignment = .leading
        self.withBackButton = false
        self.tabBarIsVisible = tabBarIsVisible
        self.showNavBar = false
        self.onRefresh = nil
        self.navBarItems = { EmptyView() }
        self.content = content
    }
}

// MARK: - CustomScrollView Builder
extension CustomScrollView {
    private var background: some View {
        Color.citizen.background
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var refreshBand: some View {
        if onRefresh != nil {
            ProgressView()
                .tint(Color.citizen.accent)
                .frame(maxWidth: .infinity)
                .frame(height: isRefreshing ? refreshBandHeight : 0)
                .opacity(isRefreshing ? 1 : 0)
                .clipped()
        }
    }
    
    private var scroll: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    refreshBand
                    content(proxy)
                        .padding(.top, 10)
                    Spacer()
                        .frame(height: isFaceIDPhone ? 10 : 30)
                        .padding(.bottom, tabBarIsVisible ? tabBarState.height : 0)
                }
            }
            .onScrollGeometryChange(for: Bool.self) { geo in
                geo.contentOffset.y < -110
            } action: { _, newValue in
                if navState.isInteracting {
                    withAnimation(.easeOut(duration: 0.2)) {
                        navState.isLarge = newValue
                    }
                } else {
                    navState.isLarge = newValue
                }
            }
            .onScrollGeometryChange(for: Bool.self) { geo in
                -(geo.contentOffset.y + geo.contentInsets.top) > pullDistance
            } action: { _, pulled in
                guard onRefresh != nil, !isRefreshing else { return }
                pulledEnough = pulled
            }
            .onScrollPhaseChange { _, newPhase in
                navState.isInteracting = newPhase != .idle
                if pulledEnough, !isRefreshing,
                   newPhase != .interacting, newPhase != .tracking {
                    startRefresh()
                }
            }
            .safeAreaPadding(.horizontal)
            .safeAreaPadding(.top, showNavBar ? 86 : 0)
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(withBackButton ? .automatic : .never)
        }
    }
}

// MARK: - CustomScrollView Logic
extension CustomScrollView {
    private func startRefresh() {
        guard let onRefresh else { return }
        pulledEnough = false
        withAnimation(.easeOut(duration: 0.25)) { isRefreshing = true }
        
        Task {
            let start = Date()
            await onRefresh()
            
            let elapsed = Date().timeIntervalSince(start)
            
            if elapsed < minSpinnerDuration {
                try? await Task.sleep(for: .seconds(minSpinnerDuration - elapsed))
            }
            
            withAnimation(.easeOut(duration: 0.25)) { isRefreshing = false }
        }
    }
    
    private func closeKeyboard() {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .endEditing(true)
    }
}

// MARK: - Navigation Bar State
@Observable
fileprivate final class NavBarState {
    var isLarge: Bool = true
    var isInteracting: Bool = false
}

// MARK: - Navigation Bar
private struct NavigationBarView<NavBarItems: View>: View {
    private var textAlignment: TextAlignment {
        switch alignment {
        case .leading:  return .leading
        case .trailing: return .trailing
        default:        return .center
        }
    }
    
    private let navState: NavBarState
    private let title: String
    private let subTitle: String?
    private let alignment: HorizontalAlignment
    private let withBackButton: Bool
    private let onBack: () -> Void
    
    private let largeNavBarHeight: CGFloat = 70.0
    private let smallNavBarHeight: CGFloat = 50.0
    
    @ViewBuilder private let navBarItems: () -> NavBarItems
    
    init(
        navState: NavBarState,
        title: String,
        subTitle: String?,
        alignment: HorizontalAlignment,
        withBackButton: Bool,
        onBack: @escaping () -> Void,
        @ViewBuilder navBarItems: @escaping () -> NavBarItems
    ) {
        self.navState = navState
        self.title = title
        self.subTitle = subTitle
        self.alignment = alignment
        self.withBackButton = withBackButton
        self.onBack = onBack
        self.navBarItems = navBarItems
    }
    
    var body: some View {
        ZStack {
            ZStack {
                UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                    .foregroundStyle(.ultraThinMaterial)
                UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                    .foregroundStyle(Color.citizen.groupBackground.opacity(0.5))
            }
            .ignoresSafeArea()
            .opacity(navState.isLarge ? 0 : 1)
            .shadow(color: Color.citizen.navBarShadow, radius: navState.isLarge ? 0 : 5)
            .compositingGroup()
            
            HStack {
                backButton
                titleView
                Spacer()
                navBarItems()
            }
            .padding(.trailing, 14)
            .padding(.leading, withBackButton ? 0 : 20)
        }
        .frame(height: navState.isLarge ? largeNavBarHeight : smallNavBarHeight)
    }
    
    @ViewBuilder
    private var backButton: some View {
        if withBackButton {
            Button(action: onBack) {
                Image.system.back
                    .fontWeight(.light)
                    .foregroundStyle(Color.citizen.blackAndWhite)
                    .padding(.leading, 8)
                    .frame(
                        width: 50,
                        height: navState.isLarge ? largeNavBarHeight : smallNavBarHeight
                    )
            }
        }
    }
    
    private var titleView: some View {
        VStack(alignment: alignment) {
            Text(title)
                .font(navState.isLarge ? .title : .title3)
                .fontWeight(.medium)
                .foregroundStyle(Color.citizen.blackAndWhite)
                .multilineTextAlignment(textAlignment)
                .lineLimit(1)
            
            if navState.isLarge, let subTitle {
                Text(subTitle)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.citizen.mainText)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .fontDesign(.rounded)
    }
}
