import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    
    @State private var cardName = ""
    @State private var cardNumber = ""
    @State private var selectedColor = "#0000FF"
    @State private var showingScanner = false
    
    private let colors = [
        "#0000FF", "#FF0000", "#00AA88", 
        "#000000", "#4B0082", "#800080"
    ]
    
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
            .navigationTitle(LocalizedStringKey("Add Card"))
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
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView(cardNumber: $cardNumber)
            }
        }
    }
    
    private func saveCard() {
        let shortName = String(cardName.prefix(1).uppercased())
        let newCard = Card(
            name: cardName,
            cardNumber: cardNumber,
            logoName: cardName.lowercased(),
            backgroundColor: selectedColor,
            shortName: shortName
        )
        cardStore.addCard(newCard)
        dismiss()
    }
} 