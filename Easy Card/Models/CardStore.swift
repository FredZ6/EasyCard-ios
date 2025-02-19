import Foundation

class CardStore: ObservableObject {
    @Published private(set) var cards: [Card] = []
    private let saveKey = "SavedCards"
    
    @Published private(set) var receipts: [Receipt] = []
    @Published var searchText = ""
    
    private let receiptsKey = "SavedReceipts"
    
    init() {
        loadCards()
        loadReceipts()
        
        // 如果没有收据数据，添加示例数据
        if receipts.isEmpty {
            receipts = [
                Receipt(
                    id: UUID(),
                    name: "Walmart",
                    date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
                    note: "Weekly grocery shopping",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "Starbucks",
                    date: Date().addingTimeInterval(-86400), // 1 day ago
                    note: "Coffee with friends",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "Target",
                    date: Date(),
                    note: "Home supplies",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "Apple Store",
                    date: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                    note: "Phone case and charger",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "McDonald's",
                    date: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                    note: "Lunch",
                    images: []
                )
            ]
            saveReceipts()
        }
    }
    
    func addCard(_ card: Card) {
        cards.append(card)
        saveCards()
    }
    
    func updateCard(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            saveCards()
        }
    }
    
    func deleteCard(_ card: Card) {
        cards.removeAll { $0.id == card.id }
        saveCards()
    }
    
    func moveCard(fromIndex: Int, toIndex: Int) {
        let card = cards.remove(at: fromIndex)
        cards.insert(card, at: toIndex)
        saveCards()
    }
    
    private func loadCards() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
                return
            }
        }
        cards = Card.sampleCards
    }
    
    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // 加载收据
    private func loadReceipts() {
        if let data = UserDefaults.standard.data(forKey: receiptsKey) {
            if let decoded = try? JSONDecoder().decode([Receipt].self, from: data) {
                receipts = decoded
            }
        }
    }
    
    // 保存收据
    private func saveReceipts() {
        if let encoded = try? JSONEncoder().encode(receipts) {
            UserDefaults.standard.set(encoded, forKey: receiptsKey)
            print("💿 Receipts saved to UserDefaults - Count: \(receipts.count)")
        } else {
            print("❌ Failed to encode receipts")
        }
    }
    
    // 添加收据
    func addReceipt(_ receipt: Receipt) {
        print("📥 Starting to add receipt - Name: \(receipt.name)")
        print("📊 Before adding - Current receipts count: \(receipts.count)")
        
        var newReceipt = receipt
        newReceipt.id = UUID()
        print("🆔 Generated new ID: \(newReceipt.id)")
        
        receipts.append(newReceipt)
        print("📊 After adding - Current receipts count: \(receipts.count)")
        
        saveReceipts()
        print("💾 Saved to UserDefaults")
        
        // 验证保存
        if let data = UserDefaults.standard.data(forKey: receiptsKey),
           let savedReceipts = try? JSONDecoder().decode([Receipt].self, from: data) {
            print("✅ Verified save - Saved receipts count: \(savedReceipts.count)")
        } else {
            print("❌ Failed to verify save")
        }
    }
    
    // 更新收据
    func updateReceipt(_ receipt: Receipt) {
        if let index = receipts.firstIndex(where: { $0.id == receipt.id }) {
            receipts[index] = receipt
            saveReceipts()
        }
    }
    
    // 删除收据
    func deleteReceipt(_ receipt: Receipt) {
        receipts.removeAll { $0.id == receipt.id }
        saveReceipts()
    }
} 