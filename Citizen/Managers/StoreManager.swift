//
//  StoreManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import RevenueCat

@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var hasGrant: Bool
    @Published private(set) var serverPremium: Bool
    @Published private(set) var activeEntitlement: EntitlementInfo?
    @Published private(set) var packages: [Package] = []
    @Published private(set) var didLoadCustomerInfo = false
    
    var isPremium: Bool { hasGrant || serverPremium || activeEntitlement != nil }
    var activeProductID: String? { activeEntitlement?.productIdentifier }
    
    private var customerInfoTask: Task<Void, Never>? = nil
    
    private let entitlementID = Plist.get(.revenueCatEntitlement)
    
    init() {
        hasGrant = UserDefaults.standard.bool(forKey: AppStorageKey.grantPremium.key)
        serverPremium = UserDefaults.standard.bool(forKey: AppStorageKey.serverPremium.key)
        customerInfoTask = observeCustomerInfo()
        Task {
            await refreshCustomerInfo()
            await loadPackages()
        }
    }
    
    deinit {
        customerInfoTask?.cancel()
    }
    
    func applyGrant(_ value: Bool) {
        hasGrant = value
    }
    
    func applyServerPremium(_ value: Bool) {
        serverPremium = value
    }
    
    func loadPackages() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            packages = offerings.current?.availablePackages ?? []
        } catch {
        }
    }
    
    func package(forProductID id: String) -> Package? {
        packages.first { $0.storeProduct.productIdentifier == id }
    }
    
    func purchase(_ package: Package) async throws {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            guard !result.userCancelled else { return }
            update(with: result.customerInfo)
        } catch {
            throw StoreError.system
        }
    }
    
    func restorePurchases() async throws {
        do {
            let info = try await Purchases.shared.restorePurchases()
            update(with: info)
        } catch {
            throw StoreError.syncError
        }
    }
    
    private func observeCustomerInfo() -> Task<Void, Never> {
        Task { [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                self?.update(with: info)
            }
        }
    }
    
    private func refreshCustomerInfo() async {
        guard let info = try? await Purchases.shared.customerInfo() else { return }
        update(with: info)
    }
    
    private func update(with info: CustomerInfo) {
        activeEntitlement = info.entitlements.active[entitlementID]
        didLoadCustomerInfo = true
    }
}
