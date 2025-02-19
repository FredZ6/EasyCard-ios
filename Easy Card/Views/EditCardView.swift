import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    @State private var card: Card
    
    private let colors = [
        "#0000FF", "#FF0000", "#00AA88", 
        "#000000", "#4B0082", "#800080"
    ]
    
    init(card: Card) {
        _card = State(initialValue: card)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $card.name)
                TextField("Card Number", text: $card.cardNumber)
                    .keyboardType(.numberPad)
            }
            
            Section("Card Color") {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 44))
                ], spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: card.backgroundColor == color ? 3 : 0)
                            )
                            .onTapGesture {
                                card.backgroundColor = color
                            }
                    }
                }
            }
        }
        .navigationTitle(card.id == UUID() ? "New Card" : "Edit Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onDisappear {
            saveCard()
        }
    }
    
    private func saveCard() {
        if card.id == UUID() {
            cardStore.addCard(card)
        } else {
            cardStore.updateCard(card)
        }
    }
} 