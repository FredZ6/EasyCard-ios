import SwiftUI

struct ReceiptsView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var showingAddReceipt = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredReceipts: [Receipt] {
        if searchText.isEmpty {
            return cardStore.receipts
        } else {
            return cardStore.receipts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Simple Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search Receipts", text: $searchText)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
            
            // Receipts Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredReceipts) { receipt in
                        NavigationLink(destination: ReceiptEditView(receipt: receipt)) {
                            ReceiptCardView(receipt: receipt)
                        }
                    }
                }
                .padding()
            }
        }
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
            Color(hex: "0000FF"),  // Blue
            Color(hex: "FF0000"),  // Red
            Color(hex: "00AA88"),  // Teal
            Color(hex: "000000"),  // Black
            Color(hex: "4B0082"),  // Indigo
            Color(hex: "800080")   // Purple
        ]
        let index = abs(receipt.id.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(receipt.name)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text(receipt.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))  // Semi-transparent white
        }
        .frame(height: 120)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        ReceiptsView()
            .environmentObject(CardStore())
    }
} 