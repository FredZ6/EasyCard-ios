import SwiftUI
import PhotosUI

struct PhotosView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    let card: Card
    
    @State private var showingImagePicker = false
    @State private var showingDeleteAlert = false
    @State private var selectedPhotoID: UUID?
    @State private var imageSelection: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            Group {
                if card.photos.isEmpty {
                    EmptyPhotoView()
                } else {
                    PhotoGridView(
                        photos: card.photos,
                        onDeletePhoto: { photoID in
                            selectedPhotoID = photoID
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .navigationTitle(LocalizedStringKey("Photos"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("Done")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    PhotosPicker(
                        selection: $imageSelection,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: imageSelection) { _, newItems in
                Task {
                    var newPhotos: [CardPhoto] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            newPhotos.append(CardPhoto(imageData: data))
                        }
                    }
                    if !newPhotos.isEmpty {
                        var updatedCard = card
                        updatedCard.photos.append(contentsOf: newPhotos)
                        cardStore.updateCard(updatedCard)
                    }
                    imageSelection.removeAll()
                }
            }
            .alert(LocalizedStringKey("Delete Photo"), isPresented: $showingDeleteAlert) {
                Button(LocalizedStringKey("Delete"), role: .destructive) {
                    deletePhoto()
                }
                Button(LocalizedStringKey("Cancel"), role: .cancel) {
                    selectedPhotoID = nil
                }
            } message: {
                Text(LocalizedStringKey("Delete Photo Warning"))
            }
        }
    }
    
    private func deletePhoto() {
        guard let photoID = selectedPhotoID else { return }
        var updatedCard = card
        updatedCard.photos.removeAll { $0.id == photoID }
        cardStore.updateCard(updatedCard)
        selectedPhotoID = nil
    }
}

// MARK: - Subviews
private struct EmptyPhotoView: View {
    var body: some View {
        ContentUnavailableView(
            LocalizedStringKey("No Photos"),
            systemImage: "photo.on.rectangle",
            description: Text(LocalizedStringKey("Add photos to your card"))
        )
    }
}

private struct PhotoGridView: View {
    let photos: [CardPhoto]
    let onDeletePhoto: (UUID) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(photos) { photo in
                    PhotoGridItem(photo: photo, onDelete: onDeletePhoto)
                }
            }
            .padding()
        }
    }
}

private struct PhotoGridItem: View {
    let photo: CardPhoto
    let onDelete: (UUID) -> Void
    
    var body: some View {
        if let uiImage = UIImage(data: photo.imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contextMenu {
                    Button(role: .destructive) {
                        onDelete(photo.id)
                    } label: {
                        Label(LocalizedStringKey("Delete Photo"), systemImage: "trash")
                    }
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    } label: {
                        Label(LocalizedStringKey("Save to Photos"), systemImage: "square.and.arrow.down")
                    }
                }
        }
    }
} 