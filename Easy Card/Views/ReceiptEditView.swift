import SwiftUI

struct ReceiptEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    
    @State private var receipt: Receipt
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var showingImagePreview = false
    @State private var showingImageSourceOptions = false
    @State private var selectedImagePath: String?
    
    init(receipt: Receipt) {
        _receipt = State(initialValue: receipt)
    }
    
    private func deleteImage(_ imagePath: String) {
        try? FileManager.default.removeItem(atPath: imagePath)
        receipt.images.removeAll { $0 == imagePath }
        cardStore.updateReceipt(receipt)
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name:")
                        .foregroundColor(.secondary)
                    TextField("Enter name", text: $receipt.name)
                }
                
                HStack {
                    Text("Date:")
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $receipt.date, displayedComponents: [.date])
                        .labelsHidden()
                }
            }
            
            Section("Notes") {
                TextEditor(text: $receipt.note)
                    .frame(minHeight: 100)
            }
            
            Section {
                if receipt.images.isEmpty {
                    Button {
                        showingImageSourceOptions = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Photo")
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 10) {
                            ForEach(receipt.images, id: \.self) { imagePath in
                                if let uiImage = UIImage(contentsOfFile: imagePath) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .onTapGesture {
                                            selectedImage = uiImage
                                            showingImagePreview = true
                                            selectedImagePath = imagePath
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                    
                    Button("Add Photo") {
                        showingImageSourceOptions = true
                    }
                }
            } header: {
                Text("Photos")
            }
        }
        .navigationTitle(receipt.id == UUID() ? "New Receipt" : "Edit Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if receipt.id == UUID() {
                        cardStore.addReceipt(receipt)
                    } else {
                        cardStore.updateReceipt(receipt)
                    }
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            CustomImagePicker(images: $receipt.images)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(images: $receipt.images)
        }
        .fullScreenCover(isPresented: $showingImagePreview) {
            ImagePreviewView(
                image: selectedImage,
                isPresented: $showingImagePreview,
                imagePath: selectedImagePath ?? "",
                onDelete: deleteImage
            )
        }
        .confirmationDialog("Choose Photo Source", isPresented: $showingImageSourceOptions) {
            Button("Take Photo") {
                showingCamera = true
            }
            Button("Choose from Library") {
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct ImagePreviewView: View {
    let image: UIImage?
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var showingDeleteConfirmation = false
    let imagePath: String
    let onDelete: (String) -> Void
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = scale * delta
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                }
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .alert("Delete Photo", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete(imagePath)
                isPresented = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this photo? This action cannot be undone.")
        }
    }
}

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var images: [String]
    
    var body: some View {
        CameraImagePicker(sourceType: .camera, onImagePicked: { image in
            if let data = image.jpegData(compressionQuality: 0.8) {
                let filename = UUID().uuidString + ".jpg"
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                
                try? data.write(to: fileURL)
                images.append(fileURL.path)
            }
            dismiss()
        })
    }
}

struct CameraImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        
        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
} 
