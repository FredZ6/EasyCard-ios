import SwiftUI

struct NoteEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    let card: Card
    
    @State private var note: String
    
    init(card: Card) {
        self.card = card
        _note = State(initialValue: card.note)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
                
                if !note.isEmpty {
                    Section {
                        Button(role: .destructive) {
                            note = ""
                        } label: {
                            Label(LocalizedStringKey("Clear Note"), systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("Edit Note"))
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
        updatedCard.note = note
        cardStore.updateCard(updatedCard)
        dismiss()
    }
} 