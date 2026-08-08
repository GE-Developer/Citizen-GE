//
//  StyleView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct StyleView: View {
    @EnvironmentObject private var store: StoreManager
    @State private var showPayWall = false
    
    private let vm = StyleViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        styleView
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
    }
}

// MARK: - Builder
extension StyleView {
    private var styleView: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            TopViewHeaderText(text: vm.headerText)
            accentGrid
        }
    }
    
    private var accentGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(vm.colorCases) { colorCase in
                accentButton(for: colorCase)
                    .disabled(vm.isCurrent(colorCase))
                    .premiumOption($showPayWall, isIncluded: colorCase.requiresPremium)
                    .overlay(premiumOverlay(colorCase))
            }
        }
    }
    
    private func accentButton(for colorCase: AccentColor) -> some View {
        Button(action: { vm.changeAccent(to: colorCase) }) {
            VStack(spacing: 12) {
                Image.system.checkmarkInCircle(vm.isCurrent(colorCase))
                    .foregroundStyle(colorCase.gradient)
                Text(colorCase.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.citizen.mainText)
                Divider()
                MatrixAnimationView(
                    .georgian,
                    color: colorCase.gradient,
                    letterSize: 14,
                    rowSpacing: 1,
                    updateDelay: 99999
                )
                HStack {
                    Spacer()
                    Image.system.reviewLike
                    Spacer()
                    Image.system.vibration
                    Spacer()
                    Image.system.star
                    Spacer()
                    Image.system.send
                    Spacer()
                }
                .foregroundStyle(colorCase.gradient)
            }
            .aspectRatio(0.7, contentMode: .fit)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.citizen.secondaryGroupBackground)
                    .shadow(color: .citizen.viewShadow, radius: 2)
            }
            .padding(2)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        vm.isCurrent(colorCase) ? colorCase.color : .clear,
                        lineWidth: 2
                    )
            }
        }
    }
    
    @ViewBuilder
    private func premiumOverlay(_ colorCase: AccentColor) -> some View {
        if colorCase.requiresPremium {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PremiumView(.star)
                        .padding(4)
                        .background {
                            Circle()
                                .fill(Color.citizen.background)
                                .shadow(color: Color.citizen.background, radius: 2)
                        }
                        .offset(x: 10, y: 10)
                }
            }
        }
    }
}
