import Foundation
import SwiftUI

enum SortOption: String, CaseIterable {
    case nameAsc = "nameAsc"
    case nameDesc = "nameDesc"
    case newest = "newest"
    case oldest = "oldest"
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .nameAsc:
            return LocalizedStringKey("Name (A to Z)")
        case .nameDesc:
            return LocalizedStringKey("Name (Z to A)")
        case .newest:
            return LocalizedStringKey("Newest First")
        case .oldest:
            return LocalizedStringKey("Oldest First")
        }
    }
    
    func sort(_ cards: [Card]) -> [Card] {
        switch self {
        case .nameAsc:
            return cards.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDesc:
            return cards.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }
        case .newest:
            return cards.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return cards.sorted { $0.createdAt < $1.createdAt }
        }
    }
} 