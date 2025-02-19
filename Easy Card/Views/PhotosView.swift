import SwiftUI
import PhotosUI

struct PhotosView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    @State private var card: Card
    @State private var showingDeleteAlert = false
    @State private var selectedPhotoID: UUID?
    @State private var imageSelection: [PhotosPickerItem] = []
    
    init(card: Card) {
        _card = State(initialValue: card)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if card.photos.isEmpty {
                    EmptyPhotoView()
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 12
                        ) {
                            ForEach(card.photos) { photo in
                                if let uiImage = UIImage(contentsOfFile: photo.imagePath) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(
                                            width: (UIScreen.main.bounds.width - 48) / 3,
                                            height: (UIScreen.main.bounds.width - 48) / 3
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                selectedPhotoID = photo.id
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("Delete Photo", systemImage: "trash")
                                            }
                                            
                                            Button {
                                                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                                            } label: {
                                                Label("Save to Photos", systemImage: "square.and.arrow.down")
                                            }
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(
                        selection: $imageSelection,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: imageSelection) { _, newItems in
                Task {
                    var newPhotos: [CardPhoto] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            let filename = UUID().uuidString + ".jpg"
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                            
                            try? data.write(to: fileURL)
                            
                            newPhotos.append(CardPhoto(imagePath: fileURL.path))
                        }
                    }
                    if !newPhotos.isEmpty {
                        card.photos.append(contentsOf: newPhotos)
                        cardStore.updateCard(card)
                    }
                    imageSelection.removeAll()
                }
            }
            .alert("Delete Photo", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deletePhoto()
                }
                Button("Cancel", role: .cancel) {
                    selectedPhotoID = nil
                }
            } message: {
                Text("Are you sure you want to delete this photo?")
            }
        }
    }
    
    private func deletePhoto() {
        guard let photoID = selectedPhotoID else { return }
        card.photos.removeAll { $0.id == photoID }
        cardStore.updateCard(card)
        selectedPhotoID = nil
    }
}

// MARK: - Subviews
private struct EmptyPhotoView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Photos", systemImage: "photo.on.rectangle.angled")
        } description: {
            VStack(spacing: 8) {
                Text("Add photos of your membership card")
                Text("(front and back)")
                    .foregroundColor(.secondary)
                Text("Tap + to add photos")
                    .foregroundColor(.blue)
            }
        }
    }
} 

