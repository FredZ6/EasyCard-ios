//
//  EasyCardWidget.swift
//  EasyCardWidget
//
//  Created by Fred Z on 2025-02-21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), recentCards: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Get sample data for preview
        let entry = SimpleEntry(date: Date(), recentCards: getSampleCards())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get recent cards from UserDefaults (shared between app and widget)
        let recentCards = getRecentCardsFromUserDefaults()
        let entry = SimpleEntry(date: Date(), recentCards: recentCards)
        
        // Update timeline every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getRecentCardsFromUserDefaults() -> [RecentCard] {
        let userDefaults = UserDefaults(suiteName: "group.com.fredz6.Easy-Card")
        let recentCardsData = userDefaults?.array(forKey: "recentCards") as? [Data] ?? []
        return recentCardsData.compactMap { try? JSONDecoder().decode(RecentCard.self, from: $0) }
            .prefix(6)
            .map { $0 }
    }
    
    private func getSampleCards() -> [RecentCard] {
        // Sample data for preview
        return [
            RecentCard(id: "1", name: "Starbucks", backgroundColor: "#00704A"),
            RecentCard(id: "2", name: "Costco", backgroundColor: "#005DAA"),
            RecentCard(id: "3", name: "Target", backgroundColor: "#CC0000"),
            RecentCard(id: "4", name: "Walmart", backgroundColor: "#004C91"),
            RecentCard(id: "5", name: "CVS", backgroundColor: "#CC0000"),
            RecentCard(id: "6", name: "Walgreens", backgroundColor: "#FF0000")
        ]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let recentCards: [RecentCard]
}

struct RecentCard: Codable, Identifiable {
    let id: String
    let name: String
    let backgroundColor: String
}

struct EasyCardWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Recent Cards")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(entry.recentCards) { card in
                    Link(destination: URL(string: "easycard://card/\(card.id)")!) {
                        CardView(card: card)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
    }
}

struct CardView: View {
    let card: RecentCard
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: card.backgroundColor))
            .overlay(
                Text(card.name)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            )
            .frame(height: 40)
    }
}

struct EasyCardWidget: Widget {
    let kind: String = "EasyCardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EasyCardWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recent Cards")
        .description("Quick access to your recently used cards.")
        .supportedFamilies([.systemMedium])
    }
}

// Helper extension for color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
