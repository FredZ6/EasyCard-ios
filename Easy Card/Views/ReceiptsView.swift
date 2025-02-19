import SwiftUI

struct ReceiptsView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var showingAddReceipt = false
    
    var filteredReceipts: [Receipt] {
        if searchText.isEmpty {
            return cardStore.receipts
        } else {
            return cardStore.receipts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredReceipts) { receipt in
                NavigationLink(destination: ReceiptEditView(receipt: receipt)) {
                    VStack(alignment: .leading) {
                        Text(receipt.name)
                            .font(.headline)
                        Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索收据")
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

#Preview {
    NavigationStack {
        ReceiptsView()
            .environmentObject(CardStore())
    }
} 