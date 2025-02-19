import SwiftUI

struct ReceiptsView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var showingAddReceipt = false
    
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)  // 与 Cards 相同的大小
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
                            .frame(height: 160)  // 固定高度与 Cards 一致
                    }
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: "搜索收据")
        .navigationTitle("收据")
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部区域
            ZStack {
                Color(hex: "4B9CD3")  // 使用统一的蓝色
                Text(String(receipt.name.prefix(1)))
                    .font(.system(size: 40))
                    .fontWeight(.regular)
                    .foregroundColor(.white)
            }
            .frame(height: 120)  // 顶部区域占据大部分空间
            
            // 底部信息区域
            VStack(alignment: .leading) {
                Text(receipt.name)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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