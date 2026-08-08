//
//  RemoteAvatarView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct RemoteAvatarView: View {
    private enum Phase {
        case loading
        case loaded(CGImage)
        case placeholder
    }
    
    private struct TaskKey: Equatable {
        let url: String?
        let online: Bool
    }
    
    @State private var phase: Phase = .loading
    
    private let urlString: String?
    private let size: CGFloat
    private let showBorder: Bool
    private let placeholder: Image
    
    init(
        urlString: String?,
        size: CGFloat,
        showBorder: Bool = true,
        placeholder: Image = Image.system.person
    ) {
        self.urlString = urlString
        self.size = size
        self.showBorder = showBorder
        self.placeholder = placeholder
    }
    
    var body: some View {
        avatar
            .task(
                id: TaskKey(url: urlString, online: NetworkMonitor.shared.isConnected)
            ) {
                await loadAvatar()
            }
    }
}

// MARK: - Builder
extension RemoteAvatarView {
    private var avatar: some View {
        ZStack {
            switch phase {
            case .loaded(let image):
                Image.avatar(image)
                    .resizable()
                    .scaledToFill()
            case .loading:
                Circle()
                    .fill(Gradient.accent.opacity(0.15))
                ProgressView()
                    .tint(Color.citizen.accent)
            case .placeholder:
                Circle()
                    .fill(Gradient.accent.opacity(0.15))
                placeholder
                    .font(.system(size: size * 0.42, weight: .medium))
                    .foregroundStyle(Gradient.accent)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .padding(4)
        .overlay {
            if showBorder {
                Circle()
                    .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 2)
            }
        }
    }
}

// MARK: - Logic
extension RemoteAvatarView {
    private func loadAvatar() async {
        guard let urlString, !urlString.isEmpty else {
            phase = .placeholder
            return
        }
        
        if case .loaded = phase {} else {
            phase = .loading
        }
        
        if let image = await RemoteImageStore.shared.image(for: urlString) {
            phase = .loaded(image)
        } else {
            phase = .placeholder
        }
    }
}
