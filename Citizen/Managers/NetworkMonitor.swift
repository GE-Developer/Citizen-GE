//
//  NetworkMonitor.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Network

@MainActor
@Observable
final class NetworkMonitor {
    private(set) var isConnected = true
    
    private var isStarted = false
    private var restoreHandlers: [() -> Void] = []
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    
    private init() {}
    
    func onRestore(_ handler: @escaping () -> Void) {
        restoreHandlers.append(handler)
    }
    
    func start() {
        guard !isStarted else { return }
        isStarted = true
        
        monitor.pathUpdateHandler = { path in
            let satisfied = path.status == .satisfied
            
            Task { @MainActor in
                Self.shared.apply(isConnected: satisfied)
            }
        }
        
        monitor.start(queue: DispatchQueue(label: "com.citizen.network-monitor"))
    }
    
    private func apply(isConnected newValue: Bool) {
        let wasConnected = isConnected
        isConnected = newValue
        
        if !wasConnected && newValue {
            restoreHandlers.forEach { $0() }
        }
    }
}
