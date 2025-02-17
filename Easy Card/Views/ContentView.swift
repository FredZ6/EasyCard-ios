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
            
            Text(LocalizedStringKey("Profile"))
                .tabItem {
                    Image(systemName: "person.circle")
                    Text(LocalizedStringKey("Profile"))
                }
        }
        .environmentObject(cardStore)
    }
}

#Preview {
    ContentView()
} 