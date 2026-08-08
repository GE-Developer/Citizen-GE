//
//  LeaderboardView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct LeaderboardView: View {
    @State private var vm = LeaderboardViewModel()
    
    var body: some View {
        content
            .task { await vm.load() }
    }
}

// MARK: - Builder
extension LeaderboardView {
    private var content: some View {
        CustomScrollView(
            title: vm.title,
            onRefresh: { await vm.load() },
            navBarItems: { EmptyView() }
        ) { _ in
            scrollContent
        }
    }
    
    @ViewBuilder
    private var scrollContent: some View {
        switch vm.phase {
        case .loading:
            loadingState
        case .failed:
            failureState
        case .loaded:
            VStack(spacing: 14) {
                if let rankText = vm.myRankText {
                    CountHeaderView(count: rankText, suffix: vm.rankSuffix)
                }
                
                LazyVStack(spacing: 10) {
                    let entries = Array(vm.entries.enumerated())
                    ForEach(entries, id: \.element.id) { index, entry in
                        row(index: index, entry: entry)
                    }
                }
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.9),
                    value: vm.entries.map(\.id)
                )
            }
        }
    }
    
    @ViewBuilder
    private func row(index: Int, entry: LeaderboardEntry) -> some View {
        let isMe = vm.isCurrentUser(entry)
        
        HStack(spacing: 12) {
            Text(vm.rankText(for: index))
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .frame(width: 30)
            
            progressAvatar(entry)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(vm.nicknameText(entry))
                    .font(.subheadline)
                    .fontWeight(isMe ? .bold : .medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                moodChip(entry)
            }
            
            Spacer(minLength: 8)
            
            Text(vm.scoreText(entry))
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(height: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(isMe
                      ? AnyShapeStyle(Gradient.accent.opacity(0.12))
                      : AnyShapeStyle(Color.citizen.groupBackground))
                .overlay {
                    if entry.isPremium {
                        PremiumSparkleView()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
        }
        .overlay {
            if isMe {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 1)
            }
        }
        .geometryGroup()
    }
    
    @ViewBuilder
    private func moodChip(_ entry: LeaderboardEntry) -> some View {
        if let mood = vm.mood(entry) {
            MoodChipView(mood)
        }
    }
    
    @ViewBuilder
    private func progressAvatar(_ entry: LeaderboardEntry) -> some View {
        let lineWidth: CGFloat = 3
        
        RemoteAvatarView(urlString: entry.avatarURL, size: 36, showBorder: false)
            .padding(2)
            .overlay {
                Circle()
                    .inset(by: lineWidth / 2)
                    .stroke(Gradient.accent.opacity(0.15), lineWidth: lineWidth)
            }
            .overlay {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 0, to: vm.progressFraction(entry))
                    .stroke(
                        Gradient.accent,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
    }
    
    private var loadingState: some View {
        ProgressView()
            .tint(Color.citizen.accent)
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
    }
    
    private var failureState: some View {
        VStack(spacing: 16) {
            Image.system.warning
                .font(.largeTitle)
                .foregroundStyle(Color.citizen.secondaryText)
            
            Text(vm.failureTitle)
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
            
            Button {
                Task { await vm.load() }
            } label: {
                Image.system.sync
                    .font(.title2)
                    .foregroundStyle(Gradient.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
