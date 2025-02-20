import SwiftUI

struct ReceiptsView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var showingEditSheet = false
    @State private var selectedReceipt: Receipt?
    @State private var sortOption: SortOption = .date
    
    enum SortOption {
        case date
        case name
        
        var title: String {
            switch self {
            case .date: return "Date"
            case .name: return "Name"
            }
        }
    }
    
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
        return results.sorted { first, second in
            switch sortOption {
            case .date:
                return first.date > second.date
            case .name:
                return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
            }
        }
    }
    
    var groupedReceipts: [(String, [Receipt])] {
        let sorted = filteredReceipts
        
        if sortOption == .date {
            let grouped = Dictionary(grouping: sorted) { receipt in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy年MM月"
                return formatter.string(from: receipt.date)
            }
            
            return grouped.map { ($0.key, $0.value) }
                .sorted { $0.0 > $1.0 }
        } else {
            return [("All Receipts", sorted)]
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Sort By", selection: $sortOption) {
                ForEach([SortOption.date, .name], id: \.self) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
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
            
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(groupedReceipts, id: \.0) { group in
                        VStack(alignment: .leading, spacing: 16) {
                            if sortOption == .date {
                                Text(group.0)
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(group.1) { receipt in
                                    ReceiptCardView(receipt: receipt)
                                        .onTapGesture {
                                            selectedReceipt = receipt
                                            showingEditSheet = true
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
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
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            
            Text(receipt.name)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
                
                Text(receipt.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if !receipt.note.isEmpty {
                Text(receipt.note)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
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