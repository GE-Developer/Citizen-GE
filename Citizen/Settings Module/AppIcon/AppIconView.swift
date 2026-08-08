//
//  AppIconView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AppIconView: View {
    @EnvironmentObject private var store: StoreManager
    @StateObject private var vm = AppIconViewModel()
    @State private var showPayWall = false
    
    var body: some View {
        appIconView
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
    }
}

// MARK: - Builder
extension AppIconView {
    private var appIconView: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 25) {
                defaultForm
                alternativeForm
            }
            .animation(.easeOut(duration: 0.1), value: vm.currentIcon)
        }
    }
    
    private var defaultForm: some View {
        CustomForm(headerText: vm.defaultFormTitle) {
            iconRow(vm.defaulIcon)
        }
    }
    
    private var alternativeForm: some View {
        CustomForm(headerText: vm.alternativeFormTitle) {
            PremiumView(.textAndStar)
                .onTapGesture { showPayWall = true }
        } content: {
            ForEach(vm.alternativeIcons) { icon in
                iconRow(icon)
                divider(icon)
            }
            .premiumOption($showPayWall)
        }
    }
    
    private func iconRow(_ icon: AppIcon) -> some View {
        Button(action: { vm.selectIcon(icon) }) {
            HStack {
                Image(icon.id)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                vm.isCurrent(icon) ? Color.citizen.accent : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.citizen.viewShadow, radius: 3)
                Text(icon.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.citizen.mainText)
                    .padding(.horizontal, 5)
                Spacer()
                Image.system.checkmarkInCircle(vm.isCurrent(icon))
                    .foregroundStyle(Gradient.accent)
            }
            .padding(10)
        }
        .disabled(vm.isCurrent(icon))
    }
    
    @ViewBuilder
    private func divider(_ icon: AppIcon) -> some View {
        if icon != vm.alternativeIcons.last {
            Divider()
                .padding(.leading, 103)
        }
    }
}
