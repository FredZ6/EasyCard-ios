import SwiftUI

struct ReceiptsByDateView: View {
    let receipts: [Date: [Receipt]]
    
    var body: some View {
        ForEach(receipts.keys.sorted(by: >), id: \.self) { date in
            Section {
                ForEach(groupedReceipts(for: date)) { receiptGroup in
                    NavigationLink(destination: ReceiptDetailView(receipts: receiptGroup)) {
                        ReceiptGroupCardView(date: date, receipts: receiptGroup)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text(date, style: .date)
                    .font(.headline)
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }
    
    private func groupedReceipts(for date: Date) -> [[Receipt]] {
        let dailyReceipts = receipts[date] ?? []
        return stride(from: 0, to: dailyReceipts.count, by: 2).map {
            Array(dailyReceipts[$0..<min($0 + 2, dailyReceipts.count)])
        }
    }
}

struct ReceiptGroupCardView: View {
    let date: Date
    let receipts: [Receipt]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                ForEach(receipts.prefix(2)) { receipt in
                    if let image = UIImage(data: receipt.imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(6)
                            .clipped()
                    }
                }
            }
            
            Text("\(receipts.count) receipts")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 