//
//  MediaImageView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct MediaImageView: View {
    enum Sizing {
        case container(contentMode: ContentMode)
        case natural(height: CGFloat)
        case thumbnail(side: CGFloat)
    }
    
    @State private var decodedImage: CGImage?
    @State private var didFinishLoading = false
    
    private let kind: MediaKind
    private let name: String
    private let sizing: Sizing
    
    init(kind: MediaKind, name: String, sizing: Sizing = .container(contentMode: .fit)) {
        self.kind = kind
        self.name = name
        self.sizing = sizing
    }
    
    var body: some View {
        content
            .task(id: taskID) { await load() }
    }
}

// MARK: - Builder
extension MediaImageView {
    @ViewBuilder
    private var content: some View {
        switch sizing {
        case .container(let contentMode):
            containerImage(contentMode: contentMode)
        case .natural(let height):
            naturalImage(height: height)
        case .thumbnail(let side):
            thumbnailImage(side: side)
        }
    }
    
    private func thumbnailImage(side: CGFloat) -> some View {
        ZStack {
            backdrop
            
            if let image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else {
                stateIndicator
                    .transition(.opacity)
            }
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    @ViewBuilder
    private func containerImage(contentMode: ContentMode) -> some View {
        if let image {
            Image(decorative: image, scale: 1)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            Color.clear
                .overlay { stateIndicator }
        }
    }
    
    private func naturalImage(height: CGFloat) -> some View {
        ZStack {
            backdrop
            
            if let image {
                loadedImage(image)
                    .transition(.opacity)
            } else {
                stateIndicator
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }
    
    private var backdrop: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(Color.citizen.groupBackground)
    }
    
    private func loadedImage(_ image: CGImage) -> some View {
        Image(decorative: image, scale: 1)
            .resizable()
            .aspectRatio(aspectRatio(of: image), contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    @ViewBuilder
    private var stateIndicator: some View {
        if didFinishLoading {
            Image.system.photo
                .font(.title2)
                .foregroundStyle(Color.citizen.secondaryText)
        } else {
            ProgressView()
                .tint(Color.citizen.secondaryText)
        }
    }
}

// MARK: - Logic
extension MediaImageView {
    private var image: CGImage? {
        decodedImage ?? MediaStore.shared.cachedImage(kind, name: name, variant: variant)
    }
    
    private var variant: MediaStore.ImageVariant {
        if case .thumbnail = sizing {
            return .thumbnail
        }
        
        return .full
    }
    
    private var taskID: String {
        "\(kind.folder)/\(name)#\(MediaStore.shared.revision)"
    }
    
    private func aspectRatio(of image: CGImage) -> CGFloat {
        CGFloat(image.width) / CGFloat(max(image.height, 1))
    }
    
    private func load() async {
        let loaded = await MediaStore.shared.loadImage(kind, name: name, variant: variant)
        
        withAnimation(.easeInOut(duration: 0.2)) {
            decodedImage = loaded
        }
        
        didFinishLoading = true
    }
}
