import Foundation

class CardStore: ObservableObject {
    @Published private(set) var cards: [Card] = []
    private let saveKey = "SavedCards"
    
    @Published private(set) var receipts: [Receipt] = []
    @Published var searchText = ""
    
    init() {
        loadCards()
        loadReceipts()
        
        // 如果没有收据数据，添加示例数据
        if receipts.isEmpty {
            receipts = [
                Receipt(
                    id: UUID(),
                    name: "家乐福超市",
                    date: Date().addingTimeInterval(-86400 * 2), // 2天前
                    note: "周末采购生活用品",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "星巴克咖啡",
                    date: Date().addingTimeInterval(-86400), // 1天前
                    note: "和朋友下午茶",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "优衣库",
                    date: Date(),
                    note: "夏季服装购物",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "苹果商店",
                    date: Date().addingTimeInterval(-86400 * 5), // 5天前
                    note: "购买新手机壳和充电器",
                    images: []
                ),
                Receipt(
                    id: UUID(),
                    name: "肯德基",
                    date: Date().addingTimeInterval(-86400 * 3), // 3天前
                    note: "午餐",
                    images: []
                )
            ]
            saveReceipts() // 保存示例数据
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
        if let data = UserDefaults.standard.data(forKey: "receipts") {
            if let decoded = try? JSONDecoder().decode([Receipt].self, from: data) {
                receipts = decoded
            }
        }
    }
    
    // 保存收据
    private func saveReceipts() {
        if let encoded = try? JSONEncoder().encode(receipts) {
            UserDefaults.standard.set(encoded, forKey: "receipts")
        }
    }
    
    // 添加收据
    func addReceipt(_ receipt: Receipt) {
        receipts.append(receipt)
        saveReceipts()
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