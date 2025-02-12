import SwiftUI

struct ContentView: View {
    @StateObject private var cardStore = CardStore()
    
    var body: some View {
        TabView {
            NavigationStack {
                CardListView()
                    .navigationTitle(LocalizedStringKey("Wallet"))
            }
            .tabItem {
                Image(systemName: "bag")
                Text(LocalizedStringKey("Cards"))
            }
            
            Text(LocalizedStringKey("Receipts"))
                .tabItem {
                    Image(systemName: "doc.text")
                    Text(LocalizedStringKey("Receipts"))
                }
            
            Text(LocalizedStringKey("Wallet"))
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text(LocalizedStringKey("Wallet"))
                }
        }
        .environmentObject(cardStore)
    }
}

#Preview {
    ContentView()
} 