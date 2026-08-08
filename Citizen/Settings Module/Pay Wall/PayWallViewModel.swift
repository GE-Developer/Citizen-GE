//
//  PayWallViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import StoreKit
import Combine

@MainActor
final class PayWallViewModel: ObservableObject {
    @Published private(set) var inAppPurchases: [Product] = []
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var chosenProduct: Product?
    @Published private(set) var isLoading = false
    @Published private(set) var loadingError = false
    @Published private(set) var showExploseIfLifetimePurchased = false
    
    @Published var showError = false
    @Published var showFeatures = false
    
    private(set) var errorDescription: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    var subtitle: String {
        if store.hasGrant {
            return L10n("PayWall.Subtitle.lifetime")
        }
        
        if isPurchased(.monthly) {
            return L10n("PayWall.Subtitle.monthly")
        }
        
        if isPurchased(.weekly) {
            return L10n("PayWall.Subtitle.weekly")
        }
        
        return L10n("PayWall.Subtitle.default")
    }
    
    var purchaseButtonTitle: String {
        if isChosen(.monthly) {
            guard !isPurchased(.monthly) else { return L10n("PayWall.Button.manage") }
            
            return isPurchased(.weekly)
            ? L10n("PayWall.Button.upgrade")
            : L10n("PayWall.Button.subscribe")
        }
        
        if isChosen(.weekly) {
            guard !isPurchased(.weekly) else { return L10n("PayWall.Button.manage") }
            
            return L10n("PayWall.Button.subscribe")
        }
        
        return L10n("PayWall.Button.purchase")
    }
    
    var purchaseButtonDisabled: Bool {
        chosenProduct == nil || store.hasGrant
    }
    
    var monthlySaving: String? {
        guard
            let weekly = subscriptions.first(where: { $0.id == AppPurchase.weekly.id }),
            let monthly = subscriptions.first(where: { $0.id == AppPurchase.monthly.id })
        else {
            return nil
        }
        
        let weeklyPrice = weekly.price
        let monthlyPrice = monthly.price
        
        let monthlyCostIfPaidWeekly = weeklyPrice * 52 / 12
        
        let savings = 1 - (monthlyPrice / monthlyCostIfPaidWeekly)
        var percent = savings * 100
        
        var roundedPercent = Decimal()
        NSDecimalRound(&roundedPercent, &percent, 0, .plain)
        
        let percentInt = NSDecimalNumber(decimal: roundedPercent).intValue
        
        let savingText = L10n("PayWall.monthlySaving") + " " + "\(percentInt)%"
        
        return roundedPercent > 0 ? savingText : nil
    }
    
    var weeklyStatus: String? {
        if isPurchased(.monthly) {
            return L10n("PayWall.Status.notAvailable")
        } else if isPurchased(.weekly) {
            return L10n("PayWall.Status.purchased")
        }
        return L10n("PayWall.Status.popular")
    }
    
    var monthlyStatus: String? {
        isPurchased(.monthly) ? L10n("PayWall.Status.purchased") : nil
    }
    
    let title = L10n("PayWall.title")
    let termsOfUse = L10n("Settings.AboutApp.TermsOfUse.title")
    let privacyPolicy = L10n("Settings.AboutApp.PrivacyPolicy.title")
    let restorePurchasesTitle = L10n("Settings.Access.RestorePurchases.title")
    let familyShareText = L10n("PayWall.familyPlan")
    let featuresButtonTitle = L10n("PayWall.Features.buttonTitle")
    let featuresTitle = L10n("PayWall.Features.title")
    let features: [String] = [
        L10n("PayWall.Features.1"),
        L10n("PayWall.Features.2"),
        L10n("PayWall.Features.3"),
        L10n("PayWall.Features.4"),
        L10n("PayWall.Features.5"),
        L10n("PayWall.Features.6"),
        L10n("PayWall.Features.7"),
    ]
    let subscriptionDisclaimer = L10n("PayWall.subscriptionDisclaimer")
    let errorTitle = L10n("Error.title")
    let errorOK = "OK"
    
    private let haptic = HapticsManager.shared
    private let sound = SoundManager.shared
    
    private unowned let store: StoreManager
    
    init(store: StoreManager) {
        self.store = store
        
        store.$activeEntitlement
            .dropFirst()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func name(for product: Product) -> String {
        let appProduct = AppPurchase.allCases.first { $0.id == product.id }
        
        guard let appProduct else { return product.displayName }
        
        switch appProduct {
        case .weekly: return L10n("PayWall.Weekly.title")
        case .monthly: return L10n("PayWall.Monthly.title")
        }
    }
    
    func description(for product: Product) -> String {
        let appProduct = AppPurchase.allCases.first { $0.id == product.id }
        
        guard let appProduct else { return product.displayName }
        
        switch appProduct {
        case .weekly: return L10n("PayWall.Weekly.subtitle")
        case .monthly: return L10n("PayWall.Monthly.subtitle")
        }
    }
    
    func freeTrialDescription(for product: Product) async -> String? {
        guard let sub = product.subscription else { return nil }
        
        let eligible = await sub.isEligibleForIntroOffer
        guard eligible, let offer = sub.introductoryOffer else { return nil }
        
        let period = offer.period
        let days: Int
        switch period.unit {
        case .day: days = period.value
        case .week: days = period.value * 7
        case .month: days = period.value * 30
        case .year: days = period.value * 365
        @unknown default: days = period.value
        }
        
        return L10n("PayWall.trialPeriod \(days)")
    }
    
    func purchase(_ product: Product?) {
        guard let product, let package = store.package(forProductID: product.id) else { return }
        Task {
            do {
                try await store.purchase(package)
            } catch {
                let storeError = error as? StoreError
                errorDescription = storeError?.description ?? StoreError.unknown.description
                showError.toggle()
                haptic.notification(type: .error)
                sound.playSound(.errorAlert)
            }
        }
    }
    
    func tapped(on product: Product) {
        guard chosenProduct != product else { return }
        chosenProduct = product
        haptic.selectionChanged()
    }
    
    func toggleFeaturesSheet() {
        showFeatures.toggle()
        haptic.selectionChanged()
    }
    
    func showPrivacyPolicy() {
        guard let url = URL(string: Plist.get(.privacyPolicy)) else { return }
        UIApplication.shared.open(url)
    }
    
    func showTermsOfUse() {
        guard let url = URL(string: Plist.get(.termsOfUse)) else { return }
        UIApplication.shared.open(url)
    }
    
    func isWeeklyButtonDisabled(_ subscription: Product) -> Bool {
        isPurchased(.monthly) && subscription.id == AppPurchase.weekly.id
    }
    
    func restorePurchases() {
        Task {
            do {
                try await store.restorePurchases()
            } catch {
                errorDescription = StoreError.syncError.description
                showError.toggle()
                sound.playSound(.errorAlert)
                haptic.notification(type: .error)
            }
        }
    }
    
    func isPurchased(_ appPurchase: AppPurchase) -> Bool {
        store.activeProductID == appPurchase.id
    }
    
    func lifetimeAnimationAppeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showExploseIfLifetimePurchased = true
            self.haptic.notification(type: .success)
            self.sound.playSound(.devMode)
        }
    }
    
    func loadProducts() async {
        guard !isLoading else { return }
        
        loadingError = false
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        let subscriptionIDs = AppPurchase.subscriptionIDs
        
        do {
            let fetchedSubscriptions = try await Product.products(for: subscriptionIDs)
            
            guard !fetchedSubscriptions.isEmpty else {
                throw StoreError.loadingError
            }
            
            subscriptions = AppPurchase.subscriptionIDs.compactMap { id in
                fetchedSubscriptions.first(where: { $0.id == id })
            }
        } catch {
            errorDescription = StoreError.loadingError.description
            showError.toggle()
            haptic.notification(type: .error)
            sound.playSound(.errorAlert)
            loadingError = true
        }
    }
    
    private func isChosen(_ appPurchase: AppPurchase) -> Bool {
        guard let chosenProductID = chosenProduct?.id else { return false }
        
        return chosenProductID == appPurchase.id
    }
    
}
