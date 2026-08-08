//
//  AppVersion.swift
//  VOID
//
//  Created by GE-Developer
//

import SwiftUI

// MARK: - App Version
struct AppVersion: View {
    @State private var isGestureActivated = false
    @State private var showDeveloperView = false
    
    private let haptic = HapticsManager.shared
    private let sound = SoundManager.shared
    
    private let appVersion: String
    
    private var textColor: Color {
        isGestureActivated ? Color.citizen.accent : Color.citizen.grayDark
    }
    
    private var hasDevPassword: Bool {
        guard let password = GrantManager.shared.devPassword else { return false }
        return !password.isEmpty
    }
    
    init() {
        let infoDictionary = Bundle.main.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        
        appVersion = "\(version)"
    }
    
    var body: some View {
        appVersionView
            .onDisappear { isGestureActivated = false }
            .onLongPressGesture(minimumDuration: 2, perform: longGesture)
            .onTapGesture(count: 2, perform: gesture)
            .navigationDestination(isPresented: $showDeveloperView) {
                NavigationLazyView(DeveloperView())
            }
    }
    
    private var appVersionView: some View {
        ZStack {
            Color.citizen.background
            VStack {
                Text(L10n("Settings.AppVersion.title"))
                Text(appVersion)
            }
            .foregroundStyle(textColor)
            .font(.caption)
            .fontDesign(.monospaced)
            .padding(6)
            .frame(maxWidth: .infinity)
        }
    }
    
    private func longGesture() {
        guard hasDevPassword else { return }
        haptic.notification(type: .success)
        withAnimation {
            isGestureActivated.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
            guard isGestureActivated else { return }
            haptic.selectionChanged()
            withAnimation {
                isGestureActivated = false
            }
        }
    }
    
    private func gesture() {
        guard hasDevPassword, isGestureActivated else { return }
        haptic.impact(style: .heavy)
        sound.playSound(.devMode)
        showDeveloperView = true
    }
}

// MARK: - Developer View
struct DeveloperView: View {
    @State private var devAccess = false
    @State private var typePass = ""
    
    private var isButtonEnabled: Bool {
        devAccess || !typePass.isEmpty
    }
    
    private var password: String? {
        GrantManager.shared.devPassword
    }
    
    private let haptic = HapticsManager.shared
    
    private let title = "Developer Mode"
    private let cancel = "Cancel"
    private let placeHolder = "Code"
    private let noticeMessage = "If you’ve landed on this screen by accident, please leave **immediately**.   \n This area is intended solely for **debugging** and **internal testing**.   \n User interaction is not expected and may lead to **unpredictable behavior or app instability**."
    
    var body: some View {
        CustomScrollView(title: title) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 25) {
                headerView()
                logo.padding(.horizontal, 110)
                noticeView
            }
        }
    }
    
    private var noticeView: some View {
        CustomForm {
            CustomTextRow(noticeMessage)
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Button(action: lockButtonTapped) {
                Image.system.lock(devAccess)
                    .frame(width: 60)
                    .foregroundStyle(
                        devAccess
                        ? Color.citizen.greenDark
                        : Color.citizen.accent
                    )
                    .background { background() }
            }
            .disabled(!isButtonEnabled)
            .opacity(isButtonEnabled ? 1 : 0.6)
            .animation(.default, value: isButtonEnabled)
            
            CustomNavigationTextField(
                text: $typePass,
                image: .system.code,
                placeholder: placeHolder,
                cancelButtonTitle: cancel,
                deleteAction: clearTypedText
            )
            .autocapitalization(.none)
        }
    }
    
    private func background() -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.citizen.textFieldBackground)
            .shadow(color: Color.citizen.viewShadow, radius: 2)
            .frame(height: 40)
    }
    
    private func lockButtonTapped() {
        withAnimation {
            switch devAccess {
            case true:
                devAccess = false
                typePass = ""
                haptic.notification(type: .success)
            case false:
                if let password, !password.isEmpty, password == typePass {
                    devAccess = true
                    haptic.notification(type: .success)
                } else {
                    haptic.notification(type: .error)
                }
                typePass = ""
            }
        }
        
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    private func clearTypedText() {
        typePass = ""
        HapticsManager.shared.impact(style: .rigid)
    }
}
