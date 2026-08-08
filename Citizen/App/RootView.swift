//
//  RootView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var loader = AppDataLoader.shared
    
    private var loadingTitle: String {
        L10n("Root.Loading.title")
    }
    
    private var loadDataErrorTitle: String {
        L10n("Root.Error.loadFailed.title")
    }
    
    private var outOfSpaceErrorTitle: String {
        L10n("Root.Error.outOfSpace.title")
    }
    
    private var retryTitle: String {
        L10n("Root.Error.retry.title")
    }
    
    private var transition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 1.03).combined(with: .opacity),
            removal: .opacity
        )
    }
    
    var body: some View {
        content
            .feedbackToast()
            .preferredColorScheme(ThemeManager.shared.theme)
            .fixedTextSize()
            .task {
                await AuthManager.shared.purgeSessionIfReinstalled()
                ProgressSync.shared.configure()
                ProfileSync.shared.configure()
                MediaStore.shared.configure()
                AuthManager.shared.startObserving()
                await loader.start()
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhase(newPhase)
            }
    }
}

// MARK: - Builder
extension RootView {
    private var content: some View {
        ZStack {
            phaseView
                .id(loader.phase)
                .transition(transition)
        }
        .animation(.smooth, value: loader.phase)
    }
    
    @ViewBuilder
    private var phaseView: some View {
        switch loader.phase {
        case .loading:
            LoadingView(loadingTitle)
        case .needsAuth:
            AuthView()
        case .ready:
            HomeView()
        case .failed(let outOfSpace):
            failed(outOfSpace: outOfSpace)
        }
    }
    
    private func failed(outOfSpace: Bool) -> some View {
        VStack(spacing: 16) {
            Text(outOfSpace ? outOfSpaceErrorTitle : loadDataErrorTitle)
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(retryTitle) { retry() }
                .font(.body)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.citizen.background.ignoresSafeArea())
    }
}

// MARK: - Logic
extension RootView {
    private func retry() {
        Task { await loader.start() }
    }
    
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            ProgressSync.shared.flushNow()
        case .active:
            ProgressSync.shared.syncNow(.foreground)
            refreshServerState()
        default:
            break
        }
    }
    
    private func refreshServerState() {
        guard loader.phase == .ready else { return }
        
        Task {
            await AuthManager.shared.validateSessionOnServer()
            guard AuthManager.shared.isAuthenticated else { return }
            
            await ProfileSync.shared.syncOnLoad()
            await GrantManager.shared.syncOnLoad()
            await EntitlementManager.shared.syncOnLoad()
        }
    }
}
