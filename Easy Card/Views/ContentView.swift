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
            
            ReceiptsView()
                .tabItem {
                    Label("Receipts", systemImage: "doc.text")
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