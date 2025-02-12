import SwiftUI
import CoreImage

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    let card: Card
    
    @State private var barcodeImage: UIImage?
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingNoteSheet = false
    @State private var showingPhotosSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 条形码卡片
            VStack {
                Color(hex: card.backgroundColor)
                    .frame(height: 60)
                
                VStack(spacing: 16) {
                    if let image = barcodeImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                    
                    Text(card.cardNumber)
                        .font(.system(.body, design: .monospaced))
                }
                .padding()
                .background(Color.white)
            }
            .cornerRadius(12)
            .shadow(radius: 2)
            
            // 管理选项
            List {
                Button(action: { showingEditSheet = true }) {
                    Label(LocalizedStringKey("Edit Card"), systemImage: "pencil")
                }
                
                Button(action: { showingPhotosSheet = true }) {
                    Label(LocalizedStringKey("Photos"), systemImage: "photo")
                }
                
                Button(action: { showingNoteSheet = true }) {
                    Label(LocalizedStringKey("Note"), systemImage: "note.text")
                }
                
                if !card.note.isEmpty {
                    Section(header: Text(LocalizedStringKey("Note"))) {
                        Text(card.note)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !card.photos.isEmpty {
                    Section(header: Text(LocalizedStringKey("Photos"))) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(card.photos.prefix(4)) { photo in
                                    if let uiImage = UIImage(data: photo.imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                
                                if card.photos.count > 4 {
                                    Text("+\(card.photos.count - 4)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Button(action: { showingDeleteAlert = true }) {
                    Label(LocalizedStringKey("Delete Card"), systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            barcodeImage = BarcodeGenerator.generateBarcode(from: card.cardNumber)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCardView(card: card) { updatedCard in
                cardStore.updateCard(updatedCard)
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
            NoteEditView(card: card)
        }
        .sheet(isPresented: $showingPhotosSheet) {
            PhotosView(card: card)
        }
    }
} 