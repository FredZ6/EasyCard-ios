import SwiftUI

struct ContentView: View {
    @StateObject private var cardStore = CardStore()
    
    var body: some View {
        TabView {
            NavigationStack {
                CardListView()
                    .navigationTitle(LocalizedStringKey("Cards"))
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
        .environmentObject(cardStore)
    }
}

#Preview {
    ContentView()
} 