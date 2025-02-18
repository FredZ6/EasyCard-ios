import SwiftUI

struct ReceiptDetailView: View {
    let receipts: [Receipt]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(receipts) { receipt in
                    if let image = UIImage(data: receipt.imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(receipts.first?.storeName ?? "Receipts")
        .navigationBarTitleDisplayMode(.inline)
    }
} 