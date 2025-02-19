import SwiftUI

struct ReceiptsView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var showingEditSheet = false
    @State private var selectedReceipt: Receipt?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredReceipts: [Receipt] {
        let results = if searchText.isEmpty {
            cardStore.receipts
        } else {
            cardStore.receipts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        print("📋 Filtered receipts count: \(results.count)")
        print("📝 Current receipts: \(results.map { $0.name })")
        return results
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
                        ReceiptCardView(receipt: receipt)
                            .onTapGesture {
                                selectedReceipt = receipt
                                showingEditSheet = true
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Receipts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("➕ Creating new receipt")
                    let newReceipt = Receipt(
                        id: UUID(),
                        name: "",
                        date: Date()
                    )
                    print("📄 New receipt created with ID: \(newReceipt.id)")
                    selectedReceipt = newReceipt
                    showingEditSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let receipt = selectedReceipt {
                NavigationStack {
                    ReceiptEditView(receipt: receipt)
                        .environmentObject(cardStore)
                }
            }
        }
        .onChange(of: showingEditSheet) { newValue in
            if !newValue {
                print("📋 Sheet dismissed")
                selectedReceipt = nil
                // 添加验证
                print("📊 Current receipts after dismiss: \(cardStore.receipts.map { $0.name })")
            }
        }
        .onAppear {
            print("📱 ReceiptsView appeared - Current receipts count: \(cardStore.receipts.count)")
        }
    }
}

struct ReceiptCardView: View {
    let receipt: Receipt
    
    var backgroundColor: Color {
        Color(hex: "000000")  // Black
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