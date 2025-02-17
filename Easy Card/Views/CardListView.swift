import SwiftUI

struct CardListView: View {
    @EnvironmentObject private var cardStore: CardStore
    @StateObject private var searchHistory = SearchHistory()
    @State private var showingAddCard = false
    @State private var searchText = ""
    @State private var showingSortOptions = false
    @AppStorage("selectedSortOption") private var selectedSortOption = SortOption.nameAsc.rawValue
    
    var currentSortOption: SortOption {
        SortOption(rawValue: selectedSortOption) ?? .nameAsc
    }
    
    var filteredAndSortedCards: [Card] {
        let filtered = if searchText.isEmpty {
            cardStore.cards
        } else {
            cardStore.cards.filter { card in
                card.name.localizedCaseInsensitiveContains(searchText) ||
                card.cardNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        return currentSortOption.sort(filtered)
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
            if filteredAndSortedCards.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? LocalizedStringKey("No Cards") : LocalizedStringKey("No Results"),
                    systemImage: searchText.isEmpty ? "creditcard" : "magnifyingglass",
                    description: Text(searchText.isEmpty ?
                        LocalizedStringKey("Add your first card") :
                        LocalizedStringKey("Try a different search"))
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredAndSortedCards) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                CardView(card: card)
                            }
                        }
                        
                        Button(action: {
                            showingAddCard = true
                        }) {
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
                Menu {
                    Button(action: { showingAddCard = true }) {
                        Label(LocalizedStringKey("Add Card"), systemImage: "plus.circle")
                    }
                    
                    Menu(LocalizedStringKey("Sort By")) {
                        Picker(selection: $selectedSortOption) {
                            ForEach(SortOption.allCases, id: \.rawValue) { option in
                                Text(option.localizedName)
                                    .tag(option.rawValue)
                            }
                        } label: {
                            Text(LocalizedStringKey("Sort By"))
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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