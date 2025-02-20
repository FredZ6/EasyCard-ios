import SwiftUI
import CoreImage

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    @State private var showingEditSheet = false
    @State private var editedCard: Card  // Store the card being edited
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        _editedCard = State(initialValue: card)  // Initialize the card being edited
    }
    
    @State private var barcodeImage: UIImage?
    @State private var showingDeleteAlert = false
    @State private var showingNoteSheet = false
    @State private var showingPhotosSheet = false
    
    var body: some View {
        List {
            // Membership Card View
            Section {
                VStack(spacing: 0) {
                    // Top Color Area
                    Color(hex: editedCard.backgroundColor)
                        .frame(height: 60)
                        .overlay {
                            if let logoName = editedCard.logoName, 
                               let _ = UIImage(named: logoName) {
                                Image(logoName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 24)
                            }
                        }
                    
                    // Barcode Area
                    VStack(spacing: 8) {
                        if let image = barcodeImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .padding(.horizontal, 12)
                        }
                        
                        Text(editedCard.cardNumber)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 3, x: 0, y: 1)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }
            
            // Management Options
            Section {
                Button(action: { showingEditSheet = true }) {
                    Label(LocalizedStringKey("Edit Card"), systemImage: "pencil")
                }
                
                Button(action: { showingPhotosSheet = true }) {
                    Label(LocalizedStringKey("Photos"), systemImage: "photo")
                }
                
                Button(action: { showingNoteSheet = true }) {
                    Label(LocalizedStringKey("Note"), systemImage: "note.text")
                }
            }
            
            // Note Area
            if !editedCard.note.isEmpty {
                Section(header: Text(LocalizedStringKey("Note"))) {
                    Text(editedCard.note)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            // Delete Button
            Section {
                Button(action: { showingDeleteAlert = true }) {
                    Label(LocalizedStringKey("Delete Card"), systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(editedCard.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateBarcodeImage()
        }
        .onChange(of: editedCard.cardNumber) { _, _ in
            // Update barcode when card number changes
            updateBarcodeImage()
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditCardView(card: editedCard)  // 直接传递 Card 而不是 Binding
            }
        }
        .alert(LocalizedStringKey("Delete Confirmation"), isPresented: $showingDeleteAlert) {
            Button(LocalizedStringKey("Delete"), role: .destructive) {
                cardStore.deleteCard(card)
                dismiss()
            }
            Button(LocalizedStringKey("Cancel"), role: .cancel) {}
        } message: {
            Text(LocalizedStringKey("Delete Warning"))
        }
        .sheet(isPresented: $showingNoteSheet) {
            NoteEditView(card: editedCard)
                .onDisappear {
                    // When note edit view disappears, refresh card data from cardStore
                    if let updatedCard = cardStore.cards.first(where: { $0.id == editedCard.id }) {
                        editedCard = updatedCard
                    }
                }
        }
        .sheet(isPresented: $showingPhotosSheet) {
            PhotosView(card: editedCard)
                .onDisappear {
                    // When PhotosView disappears, get the latest card data from cardStore
                    if let updatedCard = cardStore.cards.first(where: { $0.id == editedCard.id }) {
                        editedCard = updatedCard
                    }
                }
        }
    }
    
    private func updateBarcodeImage() {
        barcodeImage = BarcodeGenerator.generateBarcode(from: editedCard.cardNumber)
    }
} 
