import SwiftUI
import CoreImage

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    @State private var showingEditSheet = false
    @State private var editedCard: Card  // 用于存储编辑中的卡片
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        _editedCard = State(initialValue: card)  // 初始化编辑中的卡片
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
            
            // Photo Preview Area
            if !editedCard.photos.isEmpty {
                Section(header: Text(LocalizedStringKey("Photos"))) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(editedCard.photos.prefix(4)) { photo in
                                if let uiImage = UIImage(data: photo.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            
                            if editedCard.photos.count > 4 {
                                Text("+\(editedCard.photos.count - 4)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets())
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
            // 当卡号改变时更新条形码
            updateBarcodeImage()
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCardView(card: $editedCard)
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
                    // 当笔记编辑视图消失时，重新从 cardStore 获取更新后的卡片数据
                    if let updatedCard = cardStore.cards.first(where: { $0.id == editedCard.id }) {
                        editedCard = updatedCard
                    }
                }
        }
        .sheet(isPresented: $showingPhotosSheet) {
            PhotosView(card: editedCard)
        }
    }
    
    private func updateBarcodeImage() {
        barcodeImage = BarcodeGenerator.generateBarcode(from: editedCard.cardNumber)
    }
} 