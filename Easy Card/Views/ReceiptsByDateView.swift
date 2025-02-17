import SwiftUI

struct ReceiptsByDateView: View {
    let receipts: [Date: [Receipt]]
    
    var body: some View {
        ForEach(receipts.keys.sorted(by: >), id: \.self) { date in
            Section(header: Text(date, style: .date)) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(receipts[date] ?? []) { receipt in
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