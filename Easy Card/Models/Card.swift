import Foundation

struct Card: Identifiable, Codable {
    var id: UUID
    var name: String
    var cardNumber: String
    var logoName: String?
    var backgroundColor: String
    var shortName: String
    var note: String
    var photos: [CardPhoto]
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, cardNumber: String, logoName: String? = nil, backgroundColor: String, shortName: String, note: String = "", photos: [CardPhoto] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.cardNumber = cardNumber
        self.logoName = logoName
        self.backgroundColor = backgroundColor
        self.shortName = shortName
        self.note = note
        self.photos = photos
        self.createdAt = createdAt
    }
    
    static let sampleCards = [
        Card(name: "altea", cardNumber: "324 359", logoName: "altea", backgroundColor: "#0000FF", shortName: "A", note: "会员卡"),
        Card(name: "coop", cardNumber: "111222333", logoName: "coop", backgroundColor: "#0000FF", shortName: "C"),
        Card(name: "Costco Wholesale", cardNumber: "111 849 441 757", logoName: "costco", backgroundColor: "#0088AA", shortName: "C"),
        Card(name: "GameStop", cardNumber: "123456789", logoName: "gamestop", backgroundColor: "#000000", shortName: "G")
    ]
}

struct CardPhoto: Identifiable, Codable {
    var id: UUID
    var imageData: Data
    var createdAt: Date
    
    init(id: UUID = UUID(), imageData: Data, createdAt: Date = Date()) {
        self.id = id
        self.imageData = imageData
        self.createdAt = createdAt
    }
} 