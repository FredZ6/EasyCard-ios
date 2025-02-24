import Foundation
import SwiftUI

struct Receipt: Identifiable, Codable {
    var id: UUID
    var name: String
    var date: Date
    var note: String
    var images: [String] 
    
    init(id: UUID = UUID(), name: String, date: Date, note: String = "", images: [String] = []) {
        self.id = id
        self.name = name
        self.date = date
        self.note = note
        self.images = images
    }
} 