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
            .navigationTitle("照片")
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
                    Button("完成") {
                        dismiss()
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
            .alert("删除照片", isPresented: $showingDeleteAlert) {
                Button("删除", role: .destructive) {
                    deletePhoto()
                }
                Button("取消", role: .cancel) {
                    selectedPhotoID = nil
                }
            } message: {
                Text("确定要删除这张照片吗？")
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
            "暂无照片",
            systemImage: "photo.on.rectangle",
            description: Text("点击右上角添加照片")
        )
    }
}

private struct PhotoGridView: View {
    let photos: [CardPhoto]
    let onDeletePhoto: (UUID) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 10) {
                ForEach(photos) { photo in
                    if let uiImage = UIImage(data: photo.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .contextMenu {
                                Button(role: .destructive) {
                                    onDeletePhoto(photo.id)
                                } label: {
                                    Label("删除照片", systemImage: "trash")
                                }
                                
                                Button {
                                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                                } label: {
                                    Label("保存到相册", systemImage: "square.and.arrow.down")
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: photos.isEmpty ? 0 : 120)
    }
} 

