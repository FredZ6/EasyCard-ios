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
                    Label("Receipts", systemImage: "doc.text")
                }
        }
        .environmentObject(cardStore)
    }
}

#Preview {
    ContentView()
} 