import Foundation

class SearchHistory: ObservableObject {
    @Published private(set) var recentSearches: [String] = []
    private let maxHistoryItems = 10
    private let saveKey = "RecentSearches"
    
    init() {
        loadHistory()
    }
    
    func addSearch(_ text: String) {
        if !text.isEmpty {
            recentSearches.removeAll { $0 == text }
            recentSearches.insert(text, at: 0)
            if recentSearches.count > maxHistoryItems {
                recentSearches.removeLast()
            }
            saveHistory()
        }
    }
    
    func clearHistory() {
        recentSearches.removeAll()
        saveHistory()
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.stringArray(forKey: saveKey) {
            recentSearches = data
        }
    }
    
    private func saveHistory() {
        UserDefaults.standard.set(recentSearches, forKey: saveKey)
    }
} 