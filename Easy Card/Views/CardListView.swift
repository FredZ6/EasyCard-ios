import SwiftUI

struct CardListView: View {
    @EnvironmentObject private var cardStore: CardStore
    @StateObject private var searchHistory = SearchHistory()
    @State private var showingAddCard = false
    @State private var searchText = ""
    @State private var isEditMode = false
    
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
    
    var searchSuggestions: [Card] {
        if searchText.isEmpty {
            return []
        }
        return cardStore.cards.filter { card in
            card.name.localizedCaseInsensitiveContains(searchText) ||
            card.cardNumber.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if filteredCards.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? LocalizedStringKey("No Cards") : LocalizedStringKey("No Results"),
                    systemImage: searchText.isEmpty ? "creditcard" : "magnifyingglass",
                    description: Text(searchText.isEmpty ?
                        LocalizedStringKey("Add your first card") :
                        LocalizedStringKey("Try a different search"))
                )
            } else {
                ScrollView {
                    // Drag Hint Overlay
                    if isEditMode {
                        Text(LocalizedStringKey("Drag cards to reorder"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.top)
                    }
                    
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
                                    // 添加轻微的动画效果提示可拖拽
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                            .scaleEffect(0.98)
                                    )
                            }
                        } else {
                            ForEach(filteredCards) { card in
                                NavigationLink(destination: CardDetailView(card: card)) {
                                    CardView(card: card)
                                }
                            }
                        }
                        
                        Button(action: { showingAddCard = true }) {
                            AddCardButton()
                        }
                    }
                    .padding()
                }
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: LocalizedStringKey("Search cards")
        )
        .searchSuggestions {
            if searchText.isEmpty && !searchHistory.recentSearches.isEmpty {
                Section(LocalizedStringKey("Recent Searches")) {
                    ForEach(searchHistory.recentSearches, id: \.self) { search in
                        Button {
                            searchText = search
                        } label: {
                            Label(search, systemImage: "clock")
                        }
                        .searchCompletion(search)
                    }
                    
                    Button(role: .destructive) {
                        searchHistory.clearHistory()
                    } label: {
                        Label(LocalizedStringKey("Clear History"), systemImage: "trash")
                    }
                }
            }
            
            ForEach(searchSuggestions) { card in
                Button {
                    searchText = card.name
                } label: {
                    VStack(alignment: .leading) {
                        Text(card.name)
                            .font(.headline)
                        Text(card.cardNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .searchCompletion(card.name)
            }
        }
        .onChange(of: searchText) { _, newValue in
            if !newValue.isEmpty {
                searchHistory.addSearch(newValue)
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddCardView()
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
                        Button(action: { showingAddCard = true }) {
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