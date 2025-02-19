import SwiftUI

struct ReceiptsView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var showingAddReceipt = false
    
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var filteredReceipts: [Receipt] {
        if searchText.isEmpty {
            return cardStore.receipts
        } else {
            return cardStore.receipts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredReceipts) { receipt in
                    NavigationLink(destination: ReceiptEditView(receipt: receipt)) {
                        ReceiptCardView(receipt: receipt)
                            .frame(width: 160, height: 160)
                    }
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: "Search Receipts")
        .navigationTitle("Receipts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddReceipt = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddReceipt) {
            NavigationStack {
                ReceiptEditView(receipt: Receipt())
            }
        }
    }
}

struct ReceiptCardView: View {
    let receipt: Receipt
    
    var backgroundColor: Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .pink
        ]
        let index = abs(receipt.id.hashValue) % colors.count
        return colors[index].opacity(0.3)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content area
            ZStack {
                backgroundColor
                Text(receipt.name)
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            
            // Bottom date area
            Text(receipt.date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        ReceiptsView()
            .environmentObject(CardStore())
    }
} 