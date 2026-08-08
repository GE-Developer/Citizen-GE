//
//  TopicsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct TopicsView: View {
    @EnvironmentObject private var store: StoreManager
    
    @StateObject private var vm: TopicsViewModel
    
    @State private var showPayWall = false
    
    init(category: Category) {
        _vm = StateObject(wrappedValue: TopicsViewModel(category: category))
    }
    
    var body: some View {
        questionTopic
            .navigationDestination(item: $vm.chosenTopic) { topic in
                NavigationLazyView(QuestionsView(topic: topic))
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
    }
}

// MARK: - Builder
extension TopicsView {
    private var questionTopic: some View {
        CustomScrollView(title: vm.title, subTitle: vm.subtitle) {
            EmptyView()
        } content: { _ in
            topicsList
        }
    }
    
    private var topicsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(vm.topics) { topic in
                topicCard(topic)
                    .premiumOption($showPayWall, isIncluded: topic.isPremium)
                    .overlay(premiumOverlay(topic))
            }
        }
    }
    
    private func topicCard(_ topic: Topic) -> some View {
        Button(action: { vm.choose(topic) }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text(vm.numberFor(topic))
                        .font(.title3)
                        .fontWeight(.light)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)
                    
                    Text(topic.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    pillBadge(topic)
                }
                .frame(maxHeight: .infinity)
                
                Spacer()
                
                ProgressBar(questions: topic.questions)
            }
            .frame(height: 70)
            .fontDesign(.rounded)
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    @ViewBuilder
    private func pillBadge(_ topic: Topic) -> some View {
        switch topic.phase {
        case .notStarted:
            Image.system.chevron
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.secondaryText)
        case .completed:
            Image.system.checkmark
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(Gradient.green)
        case .inProgress:
            textBadge(vm.pillText(for: topic), gradient: Gradient.yellow)
        case .workingOnMistakes:
            textBadge(vm.pillText(for: topic), gradient: Gradient.red)
        }
    }
    
    @ViewBuilder
    private func textBadge(_ text: String?, gradient: LinearGradient) -> some View {
        if let text {
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(gradient)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(gradient.opacity(0.15))
                .clipShape(Capsule())
        }
    }
    
    @ViewBuilder
    private func premiumOverlay(_ topic: Topic) -> some View {
        if topic.isPremium {
            PremiumView(.star)
                .padding(4)
                .background {
                    Circle()
                        .fill(Color.citizen.background)
                        .shadow(color: Color.citizen.background, radius: 2)
                }
                .offset(x: 10, y: 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }
}
