import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var card: Card
    @EnvironmentObject private var cardStore: CardStore
    
    @State private var cardName: String
    @State private var cardNumber: String
    @State private var selectedColor: String
    @State private var showingScanner = false
    
    private let colors = [
        "#0000FF", "#FF0000", "#00AA88", 
        "#000000", "#4B0082", "#800080"
    ]
    
    init(card: Binding<Card>) {
        self._card = card
        _cardName = State(initialValue: card.wrappedValue.name)
        _cardNumber = State(initialValue: card.wrappedValue.cardNumber)
        _selectedColor = State(initialValue: card.wrappedValue.backgroundColor)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("Card Information"))) {
                    TextField(LocalizedStringKey("Merchant Name"), text: $cardName)
                    TextField(LocalizedStringKey("Card Number"), text: $cardNumber)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text(LocalizedStringKey("Card Color"))) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 44))
                    ], spacing: 8) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingScanner = true
                    }) {
                        Label(LocalizedStringKey("Scan Barcode"), systemImage: "barcode.viewfinder")
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("Edit Card"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("Save")) {
                        saveCard()
                    }
                    .disabled(cardName.isEmpty || cardNumber.isEmpty)
                }
            }
        }
        .onChange(of: cardNumber) { _, newValue in
            card.cardNumber = newValue
        }
        .onChange(of: cardName) { _, newValue in
            card.name = newValue
        }
        .onChange(of: selectedColor) { _, newValue in
            card.backgroundColor = newValue
        }
        .sheet(isPresented: $showingScanner) {
            BarcodeScannerView(cardNumber: $cardNumber)
        }
    }
    
    private func saveCard() {
        let shortName = String(cardName.prefix(1).uppercased())
        card.name = cardName
        card.cardNumber = cardNumber
        card.backgroundColor = selectedColor
        card.shortName = shortName
        card.logoName = cardName.lowercased()
        
        cardStore.updateCard(card)
        dismiss()
    }
} 