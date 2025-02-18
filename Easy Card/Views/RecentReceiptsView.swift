import SwiftUI

struct RecentReceiptsView: View {
    let receipts: [Receipt]
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(receipts) { receipt in
                NavigationLink(destination: ReceiptDetailView(receipts: [receipt])) {
                    ReceiptCardView(receipt: receipt)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

struct ReceiptCardView: View {
    let receipt: Receipt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let storeName = receipt.storeName {
                    Text(storeName)
                        .font(.headline)
                } else {
                    Text("Unknown Store")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(receipt.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let image = UIImage(data: receipt.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 