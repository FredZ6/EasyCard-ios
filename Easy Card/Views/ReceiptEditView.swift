import SwiftUI

struct ReceiptEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cardStore: CardStore
    
    @State private var receipt: Receipt
    @State private var showingImagePicker = false
    
    init(receipt: Receipt) {
        _receipt = State(initialValue: receipt)
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name:")
                        .foregroundColor(.secondary)
                    TextField("Enter name", text: $receipt.name)
                }
                
                HStack {
                    Text("Date:")
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $receipt.date, displayedComponents: [.date])
                        .labelsHidden()
                }
            }
            
            Section("Notes") {
                TextEditor(text: $receipt.note)
                    .frame(minHeight: 100)
            }
            
            Section("Photos") {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 10) {
                        ForEach(receipt.images, id: \.self) { imagePath in
                            if let uiImage = UIImage(contentsOfFile: imagePath) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: receipt.images.isEmpty ? 0 : 120)
                
                Button("Add Photo") {
                    showingImagePicker = true
                }
            }
        }
        .navigationTitle(receipt.id == UUID() ? "New Receipt" : "Edit Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if receipt.id == UUID() {
                        cardStore.addReceipt(receipt)
                    } else {
                        cardStore.updateReceipt(receipt)
                    }
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            CustomImagePicker(images: $receipt.images)
        }
    }
} 
