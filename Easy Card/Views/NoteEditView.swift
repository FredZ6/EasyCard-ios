import SwiftUI

struct NoteEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    @State private var noteText: String
    let card: Card
    
    init(card: Card) {
        self.card = card
        _noteText = State(initialValue: card.note)
    }
    
    var body: some View {
        NavigationView {
            TextEditor(text: $noteText)
                .padding()
                .navigationTitle(LocalizedStringKey("Note"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(LocalizedStringKey("Cancel")) {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button(LocalizedStringKey("Save")) {
                            saveNote()
                        }
                    }
                }
        }
    }
    
    private func saveNote() {
        var updatedCard = card
        updatedCard.note = noteText
        cardStore.updateCard(updatedCard)
        dismiss()
    }
} 