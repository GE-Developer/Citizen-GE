//
//  ExamStatsStrip.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamStatsStrip: View {
    private let stats: [ExamHeroStat]
    
    init(stats: [ExamHeroStat]) {
        self.stats = stats
    }
    
    var body: some View {
        strip
    }
}

// MARK: - Builder
extension ExamStatsStrip {
    private var strip: some View {
        HStack {
            ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                if index > 0 {
                    Divider()
                        .frame(height: 30)
                }
                
                column(stat)
            }
        }
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.citizen.darkGroupBackground)
        }
    }
    
    private func column(_ stat: ExamHeroStat) -> some View {
        VStack(spacing: 4) {
            Text(stat.value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(stat.isAccent ? Color.citizen.accent : Color.citizen.mainText)
            
            Text(stat.caption.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.secondaryText)
                .tracking(1)
        }
        .fontDesign(.rounded)
        .frame(maxWidth: .infinity)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}

// MARK: - ExamHeroStat
struct ExamHeroStat: Identifiable {
    let value: String
    let caption: String
    var isAccent = false
    
    var id: String {
        caption
    }
}
