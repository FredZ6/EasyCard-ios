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
            
            ReceiptsView()
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