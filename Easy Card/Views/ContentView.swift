import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var selectedTab = 0
    @State private var selectedCard: Card?
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CardListView()
                    .navigationTitle(LocalizedStringKey("Cards"))
            }
            .sheet(item: $selectedCard) { card in
                NavigationStack {
                    CardDetailView(card: card)
                }
            }
            .tabItem {
                Image(systemName: "creditcard")
                Text(LocalizedStringKey("Cards"))
            }
            .tag(0)
            
            NavigationStack {
                ReceiptsView()
                    .navigationTitle(LocalizedStringKey("Receipts"))
            }
            .tabItem {
                Image(systemName: "receipt")
                Text(LocalizedStringKey("Receipts"))
            }
            .tag(1)
        }
        .onOpenURL { url in
            print("📱 Received URL: \(url)")
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let idItem = components.queryItems?.first(where: { $0.name == "id" }),
                  let id = idItem.value,
                  let uuid = UUID(uuidString: id),
                  let card = cardStore.cards.first(where: { $0.id == uuid }) else {
                print("❌ Failed to parse URL or find card")
                return
            }
            
            print("✅ Found card: \(card.name)")
            selectedTab = 0
            selectedCard = card
            print("➡️ Showing card detail")
        }
    }
}

#Preview {
    ContentView()
} 