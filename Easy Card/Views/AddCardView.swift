import SwiftUI
import Vision  // 添加 Vision 框架

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    
    @State private var cardName = ""
    @State private var cardNumber = ""
    @State private var selectedColor = "#0000FF"
    @State private var showingScanner = false
    @State private var showingImagePicker = false
    @State private var showingSourceSelection = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var noteText = ""
    @State private var showingAlert = false  // 添加警告状态
    @State private var alertMessage = ""     // 添加警告信息
    
    private let colors = [
        "#0000FF", "#FF0000", "#00AA88", 
        "#000000", "#4B0082", "#800080"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("Card Information"))) {
                    TextField(LocalizedStringKey("Merchant Name"), text: $cardName)
                    TextField(LocalizedStringKey("Card Number"), text: $cardNumber)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text(LocalizedStringKey("Card Color"))) {
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
                
                Section(header: Text(LocalizedStringKey("Note"))) {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: {
                        showingSourceSelection = true
                    }) {
                        Label(LocalizedStringKey("Scan Barcode"), systemImage: "barcode.viewfinder")
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("Add Card"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("Save")) {
                        saveCard()
                    }
                    .disabled(cardName.isEmpty || cardNumber.isEmpty)
                }
            }
            .confirmationDialog(LocalizedStringKey("Choose Source"), 
                              isPresented: $showingSourceSelection) {
                Button(LocalizedStringKey("Camera")) {
                    sourceType = .camera
                    showingScanner = true
                }
                Button(LocalizedStringKey("Photo Library")) {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
                Button(LocalizedStringKey("Cancel"), role: .cancel) {}
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView(cardNumber: $cardNumber)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(isPresented: $showingImagePicker,  // 修改这行
                          sourceType: sourceType,
                          completionHandler: { image in
                    if let image = image {
                        detectBarcode(in: image)
                    }
                })
            }
        }
        .alert(LocalizedStringKey("Invalid Barcode"), isPresented: $showingAlert) {
            Button(LocalizedStringKey("OK"), role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveCard() {
        let shortName = String(cardName.prefix(1).uppercased())
        let newCard = Card(
            name: cardName,
            cardNumber: cardNumber,
            logoName: cardName.lowercased(),
            backgroundColor: selectedColor,
            shortName: shortName,
            note: noteText
        )
        cardStore.addCard(newCard)
        dismiss()
    }
    
    // 添加条形码识别方法
    private func detectBarcode(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                    self.showingImagePicker = false
                }
                return
            }
            
            // 处理检测结果
            if let results = request.results as? [VNBarcodeObservation],
               let result = results.first,
               let payload = result.payloadStringValue {
                // 成功识别到条形码
                DispatchQueue.main.async {
                    self.cardNumber = payload
                    self.showingImagePicker = false
                }
            } else {
                // 没有识别到条形码
                DispatchQueue.main.async {
                    self.alertMessage = NSLocalizedString("No valid barcode found in the image", 
                                                        comment: "Alert message when barcode detection fails")
                    self.showingAlert = true
                    self.showingImagePicker = false
                }
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
                self.showingImagePicker = false
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let sourceType: UIImagePickerController.SourceType
    let completionHandler: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, completionHandler: completionHandler)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var isPresented: Bool
        let completionHandler: (UIImage?) -> Void
        
        init(isPresented: Binding<Bool>, completionHandler: @escaping (UIImage?) -> Void) {
            self._isPresented = isPresented
            self.completionHandler = completionHandler
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            completionHandler(image)
            isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil)
            isPresented = false
        }
    }
} 