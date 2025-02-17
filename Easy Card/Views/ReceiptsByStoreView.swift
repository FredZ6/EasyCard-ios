import SwiftUI

struct ReceiptsByStoreView: View {
    let receipts: [String: [Receipt]]
    
    var body: some View {
        ForEach(receipts.keys.sorted(), id: \.self) { store in
            Section(header: Text(store)) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(receipts[store] ?? []) { receipt in
                        if let uiImage = UIImage(data: receipt.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding()
        }
    }
} 