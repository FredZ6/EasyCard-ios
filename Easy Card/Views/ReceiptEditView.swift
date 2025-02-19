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
    @State private var showingDeleteAlert = false
    private let isNewReceipt: Bool
    
    init(receipt: Receipt) {
        _receipt = State(initialValue: receipt)
        self.isNewReceipt = receipt.id == UUID()
        print("🔍 ReceiptEditView init - Receipt ID: \(receipt.id)")
        print("📌 Is new receipt: \(self.isNewReceipt)")
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
            
            if receipt.id != UUID() {
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Receipt")
                        }
                    }
                }
            }
        }
        .navigationTitle(isNewReceipt ? "New Receipt" : "Edit Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    print("💾 Starting save process...")
                    print("📝 Receipt details - Name: \(receipt.name)")
                    
                    if !cardStore.receipts.contains(where: { $0.id == receipt.id }) {
                        if !receipt.name.isEmpty {
                            print("⭐️ Adding new receipt")
                            cardStore.addReceipt(receipt)
                        } else {
                            print("⚠️ Cannot save receipt with empty name")
                            return
                        }
                    } else {
                        print("🔄 Updating existing receipt")
                        cardStore.updateReceipt(receipt)
                    }
                    print("✅ Save completed")
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
        .confirmationDialog("Choose Photo Source", isPresented: $showingImageSourceOptions) {
            Button("Take Photo") {
                showingCamera = true
            }
            Button("Choose from Library") {
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
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
        .alert("Delete Receipt", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                cardStore.deleteReceipt(receipt)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this receipt? This action cannot be undone.")
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
