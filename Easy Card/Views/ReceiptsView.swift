import SwiftUI
import PhotosUI

struct ReceiptsView: View {
    @StateObject private var receiptStore = ReceiptStore()
    @State private var showingCamera = false
    @State private var selectedCategory: ReceiptCategory = .recent
    @State private var searchText = ""
    @State private var searchType: SearchType = .store
    
    enum ReceiptCategory {
        case recent
        case byDate
        case byStore
    }
    
    enum SearchType {
        case store
        case date
    }
    
    var filteredReceipts: [Receipt] {
        guard !searchText.isEmpty else { return receiptStore.receipts }
        
        switch searchType {
        case .store:
            return receiptStore.receipts.filter { receipt in
                receipt.storeName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        case .date:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            return receiptStore.receipts.filter { receipt in
                dateFormatter.string(from: receipt.date).contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                VStack(spacing: 8) {
                    Picker("Search Type", selection: $searchType) {
                        Text("Store").tag(SearchType.store)
                        Text("Date").tag(SearchType.date)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 4)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            TextField(searchType == .store ? "Search by store name" : "Search by date (yyyy/MM/dd)", 
                                    text: $searchText)
                                .keyboardType(searchType == .date ? .numberPad : .default)
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    Text("Recent").tag(ReceiptCategory.recent)
                    Text("By Date").tag(ReceiptCategory.byDate)
                    Text("By Store").tag(ReceiptCategory.byStore)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Content based on selected category
                ScrollView {
                    switch selectedCategory {
                    case .recent:
                        RecentReceiptsView(receipts: filteredReceipts.sorted { $0.date > $1.date })
                    case .byDate:
                        ReceiptsByDateView(receipts: Dictionary(
                            grouping: filteredReceipts,
                            by: { Calendar.current.startOfDay(for: $0.date) }
                        ))
                    case .byStore:
                        ReceiptsByStoreView(receipts: Dictionary(
                            grouping: filteredReceipts,
                            by: { $0.storeName ?? "Unknown Store" }
                        ))
                    }
                }
            }
            .navigationTitle("Receipts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCamera = true }) {
                        Image(systemName: "camera")
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView { image in
                    if let image = image {
                        receiptStore.addReceipt(image: image)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Receipt Model
struct Receipt: Identifiable, Codable {
    let id: UUID
    let imageData: Data
    let date: Date
    var storeName: String?
    
    init(id: UUID = UUID(), imageData: Data, date: Date = Date(), storeName: String? = nil) {
        self.id = id
        self.imageData = imageData
        self.date = date
        self.storeName = storeName
    }
}

// Receipt Store
class ReceiptStore: ObservableObject {
    @Published private(set) var receipts: [Receipt] = []
    
    init() {
        // Create sample receipts with colored rectangles
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 300))
        
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemRed]
        var sampleReceipts: [Receipt] = []
        
        for (index, color) in colors.enumerated() {
            let image = renderer.image { context in
                color.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 200, height: 300))
            }
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let date = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
                let storeNames = ["Walmart", "Target", "Costco"]
                let receipt = Receipt(imageData: imageData, 
                                    date: date, 
                                    storeName: storeNames[index])
                sampleReceipts.append(receipt)
            }
        }
        
        receipts = sampleReceipts
    }
    
    var recentReceipts: [Receipt] {
        receipts.sorted { $0.date > $1.date }
    }
    
    var receiptsByDate: [Date: [Receipt]] {
        Dictionary(grouping: receipts) { receipt in
            Calendar.current.startOfDay(for: receipt.date)
        }
    }
    
    var receiptsByStore: [String: [Receipt]] {
        Dictionary(grouping: receipts) { receipt in
            receipt.storeName ?? "Unknown Store"
        }
    }
    
    func addReceipt(image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let receipt = Receipt(imageData: imageData)
            receipts.append(receipt)
        }
    }
}

// Camera View
struct CameraView: UIViewControllerRepresentable {
    let completion: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completion: (UIImage?) -> Void
        
        init(completion: @escaping (UIImage?) -> Void) {
            self.completion = completion
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            completion(image)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completion(nil)
            picker.dismiss(animated: true)
        }
    }
} 