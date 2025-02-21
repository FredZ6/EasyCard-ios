import SwiftUI

struct CardListView: View {
    @EnvironmentObject private var cardStore: CardStore
    @AppStorage("selectedCardId", store: UserDefaults(suiteName: "group.com.fredz6.Easy-Card"))
    private var selectedCardId: String?
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var isEditMode = false
    @State private var navigationPath = NavigationPath()
    
    var filteredCards: [Card] {
        if searchText.isEmpty {
            return cardStore.cards
        } else {
            return cardStore.cards.filter { card in
                card.name.localizedCaseInsensitiveContains(searchText) ||
                card.cardNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Simple Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField(LocalizedStringKey("Search Cards"), text: $searchText)
                    
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
            
            // Cards Grid
            ScrollView {
                if filteredCards.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? LocalizedStringKey("No Cards") : LocalizedStringKey("No Results"),
                        systemImage: searchText.isEmpty ? "creditcard" : "magnifyingglass",
                        description: Text(searchText.isEmpty ?
                            LocalizedStringKey("Add your first card") :
                            LocalizedStringKey("Try a different search"))
                    )
                    .padding(.top, 50)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        if isEditMode {
                            ForEach(filteredCards) { card in
                                CardView(card: card)
                                    .onDrag {
                                        NSItemProvider(object: card.id.uuidString as NSString)
                                    }
                                    .onDrop(of: [.text], delegate: CardDropDelegate(item: card, items: filteredCards, cardStore: cardStore))
                            }
                        } else {
                            ForEach(filteredCards) { card in
                                NavigationLink(value: card) {
                                    CardView(card: card)
                                }
                            }
                        }
                        
                        Button(action: { showingAddSheet = true }) {
                            AddCardButton()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationDestination(for: Card.self) { card in
            CardDetailView(card: card)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isEditMode {
                    Button(action: { isEditMode.toggle() }) {
                        Text(LocalizedStringKey("Sort Done"))
                            .bold()
                    }
                } else {
                    Menu {
                        Button(action: { showingAddSheet = true }) {
                            Label(LocalizedStringKey("Add Card"), systemImage: "plus.circle")
                        }
                        
                        Button(action: { isEditMode.toggle() }) {
                            Label(LocalizedStringKey("Reorder Cards"), 
                                  systemImage: "arrow.up.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCardView()
        }
        .onChange(of: selectedCardId) { oldId, newId in
            print("\n=== Card Selection Changed ===")
            print("🔄 Old ID: \(String(describing: oldId))")
            print("🔄 New ID: \(String(describing: newId))")
            
            if let idString = newId {
                print("\n🔍 Card Search Started")
                print("Looking for card with ID: \(idString)")
                
                if let uuid = UUID(uuidString: idString) {
                    print("✅ Valid UUID: \(uuid)")
                    print("📊 Available cards: \(cardStore.cards.map { "\($0.name): \($0.id)" }.joined(separator: "\n"))")
                    
                    if let card = cardStore.cards.first(where: { $0.id == uuid }) {
                        print("✅ Found card: \(card.name)")
                        navigationPath.append(card)
                        print("➡️ Added to navigation path")
                        selectedCardId = nil
                        print("🧹 Cleared selectedCardId")
                    } else {
                        print("❌ Card not found in cardStore")
                    }
                } else {
                    print("❌ Invalid UUID string: \(idString)")
                }
                print("=== Card Search Ended ===\n")
            }
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(card.shortName)
                    .font(.title)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            Text(card.name)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(height: 120)
        .padding()
        .background(Color(hex: card.backgroundColor))
        .cornerRadius(12)
    }
}

struct AddCardButton: View {
    var body: some View {
        VStack {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CardDropDelegate: DropDelegate {
    let item: Card
    let items: [Card]
    let cardStore: CardStore
    
    func performDrop(info: DropInfo) -> Bool {
        guard let fromIndex = items.firstIndex(where: { $0.id == item.id }),
              let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { string, _ in
            guard let uuidString = string as? String,
                  let toIndex = items.firstIndex(where: { $0.id.uuidString == uuidString }) else { return }
            
            DispatchQueue.main.async {
                cardStore.moveCard(fromIndex: fromIndex, toIndex: toIndex)
            }
        }
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
} 