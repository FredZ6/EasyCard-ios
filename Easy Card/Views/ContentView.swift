import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var selectedCard: Card?
    
    var body: some View {
        NavigationStack {
            CardListView()
                .sheet(item: $selectedCard) { card in
                    CardDetailView(card: card)
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