//
//  ProductButton.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI
import StoreKit

struct ProductButton: View {
    @EnvironmentObject private var vm: PayWallViewModel
    
    @State private var promoText: String? = nil
    
    private let product: Product
    private let isDisabled: Bool
    private let buttonType: ButtonType
    
    private var status: String? {
        switch product.id {
        case AppPurchase.weekly.id:
            return vm.weeklyStatus
        case AppPurchase.monthly.id:
            return vm.monthlyStatus
        default:
            return nil
        }
    }
    
    enum ButtonType {
        case horizontal
        case vertical
    }
    
    init(_ product: Product, isDisabled: Bool = false, _ buttonType: ButtonType = .vertical) {
        self.product = product
        self.isDisabled = isDisabled
        self.buttonType = buttonType
    }
    
    var body: some View {
        switch buttonType {
        case .horizontal:
            horizontalButton
        case .vertical:
            verticalButton
        }
    }
}

// MARK: - Builder
extension ProductButton {
    @ViewBuilder
    private var verticalButton: some View {
        let height: CGFloat = 170
        
        ZStack(alignment: .top) {
            background
            header
            
            VStack {
                if vm.isWeeklyButtonDisabled(product) {
                    Image.system.xmark
                        .frame(height: 18)
                } else {
                    CheckmarkView(vm.chosenProduct == product)
                }
                
                VStack(spacing: 0) {
                    subscriptionName
                    subscriptionDescription
                }
                subscriptionPrice
                
                Divider().padding(.horizontal, 10)
                Spacer()
                
                if let promoText {
                    accentSecondaryText(promoText)
                }
                
                if product.isFamilyShareable {
                    accentSecondaryText(vm.familyShareText)
                }
                
                if let status {
                    secondaryText(status)
                }
                
                Spacer()
            }
            .padding(.top, 22)
            .padding(.horizontal, 5)
            .padding(.bottom, 5)
            .fontDesign(.rounded)
            
        }
        .frame(height: height)
        .onTapGesture { vm.tapped(on: product) }
        .task { promoText = await vm.freeTrialDescription(for: product) }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
    
    private var horizontalButton: some View {
        ZStack {
            background
            HStack(spacing: 14) {
                
                CheckmarkView(vm.chosenProduct == product)
                
                VStack(alignment: .leading) {
                    subscriptionName
                    subscriptionDescription
                }
                Spacer()
                subscriptionPrice
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 14)
            .fontDesign(.rounded)
        }
        .frame(height: 80)
        .onTapGesture { vm.tapped(on: product) }
    }
    
    private var subscriptionName: some View {
        Text(vm.name(for: product))
            .font(.headline)
            .foregroundStyle(Color.citizen.mainText)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
    
    private var subscriptionDescription: some View {
        Text(vm.description(for: product))
            .font(.footnote)
            .fontWeight(.light)
            .foregroundStyle(Color.citizen.secondaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
    
    private var subscriptionPrice: some View {
        Text(product.displayPrice)
            .foregroundStyle(Color.citizen.secondaryText)
            .font(.footnote)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.citizen.secondaryGroupBackground)
            .overlay(buttonStroke(for: product))
    }
    
    @ViewBuilder
    private var header: some View {
        if product.id == AppPurchase.monthly.id {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Gradient.accent)
                if let monthlySaving = vm.monthlySaving {
                    Text(monthlySaving)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.citizen.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 6)
                }
            }
            .frame(height: 24)
            .offset(y: -12)
            .padding(.horizontal)
        }
    }
    
    private func buttonStroke(for product: Product) -> some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(
                vm.chosenProduct == product
                ? AnyShapeStyle(Gradient.accent)
                : AnyShapeStyle(Color.citizen.black),
                lineWidth: vm.chosenProduct == product ? 2 : 0.5
            )
    }
    
    private func accentSecondaryText(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.heavy)
            .foregroundStyle(Gradient.accent)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
    }
    
    private func secondaryText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
