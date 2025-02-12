import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    let card: Card
    let onSave: (Card) -> Void
    
    @State private var cardName: String
    @State private var cardNumber: String
    @State private var selectedColor: String
    @State private var showingScanner = false
    
    private let colors = [
        "#0000FF", "#FF0000", "#00AA88", 
        "#000000", "#4B0082", "#800080"
    ]
    
    init(card: Card, onSave: @escaping (Card) -> Void) {
        self.card = card
        self.onSave = onSave
        _cardName = State(initialValue: card.name)
        _cardNumber = State(initialValue: card.cardNumber)
        _selectedColor = State(initialValue: card.backgroundColor)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("卡片信息")) {
                    TextField("商家名称", text: $cardName)
                    TextField("卡号", text: $cardNumber)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("卡片颜色")) {
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
                        Label("扫描条形码", systemImage: "barcode.viewfinder")
                    }
                }
            }
            .navigationTitle("编辑卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
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
        let updatedCard = Card(
            id: card.id,
            name: cardName,
            cardNumber: cardNumber,
            logoName: cardName.lowercased(),
            backgroundColor: selectedColor,
            shortName: shortName
        )
        onSave(updatedCard)
        dismiss()
    }
} 