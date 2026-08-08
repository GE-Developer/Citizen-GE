//
//  DictionarySkeletonView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct DictionarySkeletonView: View {
    private var blockColor: Color { Color.citizen.groupBackground }
    private var barColor: Color { Color.citizen.secondaryText.opacity(0.22) }
    
    var body: some View {
        content
    }
}

// MARK: - Builder
extension DictionarySkeletonView {
    private var content: some View {
        VStack(spacing: 14) {
            alphabetCard
            countHeader
            chipsRow(count: 4)
            searchBar
            chipsRow(count: 2)
            ForEach(0..<6, id: \.self) { _ in
                wordCard
            }
        }
        .shimmering()
    }
    
    private var alphabetCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14)
                .fill(barColor)
                .frame(maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.vertical, 5)
            
            VStack(alignment: .leading, spacing: 6) {
                bar(width: 120, height: 15)
                bar(width: 80, height: 13)
            }
            Spacer()
        }
        .padding()
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Gradient.accent)
        }
    }
    
    private var countHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            bar(width: 54, height: 30)
            bar(width: 120, height: 16)
            Spacer()
        }
    }
    
    private func chipsRow(count: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { _ in
                Capsule()
                    .fill(blockColor)
                    .frame(width: 74, height: 34)
            }
            Spacer()
        }
    }
    
    private var searchBar: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(blockColor)
            .frame(height: 46)
            .frame(maxWidth: .infinity)
    }
    
    private var wordCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Capsule()
                    .fill(barColor)
                    .frame(width: 58, height: 20)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 6) {
                bar(width: 150, height: 16)
                bar(width: 96, height: 12)
                bar(width: 128, height: 12)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(blockColor)
        }
    }
    
    private func bar(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(barColor)
            .frame(width: width, height: height)
    }
}
