import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var selectedCard: Card?
    
    var body: some View {
        TabView {
            NavigationStack {
                CardListView()
                    .navigationTitle(LocalizedStringKey("Cards"))
                    .sheet(item: $selectedCard) { card in
                        CardDetailView(card: card)
                    }
            }
            .tabItem {
                Image(systemName: "creditcard")
                Text(LocalizedStringKey("Cards"))
            }
            
            NavigationStack {
                ReceiptsView()
                    .navigationTitle(LocalizedStringKey("Receipts"))
            }
            .tabItem {
                Image(systemName: "receipt")
                Text(LocalizedStringKey("Receipts"))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenCardDetail"))) { notification in
            if let cardIdString = notification.userInfo?["cardId"] as? String,
               let cardId = UUID(uuidString: cardIdString),
               let card = cardStore.cards.first(where: { $0.id == cardId }) {
                selectedCard = card
            }
        }
    }
}

#Preview {
    ContentView()
} 