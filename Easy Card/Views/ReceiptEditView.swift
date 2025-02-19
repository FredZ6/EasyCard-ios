import SwiftUI

struct ReceiptEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    
    @State private var receipt: Receipt
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var selectedImagePath: String?
    @State private var showingImagePreview = false
    @State private var showingImageSourceOptions = false
    
    init(receipt: Receipt) {
        _receipt = State(initialValue: receipt)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $receipt.name)
                DatePicker("Date", selection: $receipt.date, displayedComponents: [.date])
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
                    VStack(spacing: 16) {
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
                                                selectedImagePath = imagePath
                                                showingImagePreview = true
                                            }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 100)
                        
                        Divider()
                        
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
                    }
                }
            } header: {
                Text("Photos")
            }
        }
        .navigationTitle(receipt.id == UUID() ? "New Receipt" : "Edit Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            saveReceipt()
        }
        .sheet(isPresented: $showingImagePicker) {
            CustomImagePicker(images: $receipt.images)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(images: $receipt.images)
        }
        .fullScreenCover(isPresented: $showingImagePreview) {
            ImagePreviewView(
                image: $selectedImage,
                isPresented: $showingImagePreview,
                onDelete: {
                    if let imagePath = selectedImagePath {
                        try? FileManager.default.removeItem(atPath: imagePath)
                        receipt.images.removeAll { $0 == imagePath }
                        cardStore.updateReceipt(receipt)
                    }
                }
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
    
    private func saveReceipt() {
        if receipt.id == UUID() {
            cardStore.addReceipt(receipt)
        } else {
            cardStore.updateReceipt(receipt)
        }
    }
}

struct ImagePreviewView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @State private var showingDeleteAlert = false
    let onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .alert("Delete Photo", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    isPresented = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this photo? This action cannot be undone.")
            }
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
