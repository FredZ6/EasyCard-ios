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
                TextField("名称", text: $receipt.name)
                DatePicker("日期", selection: $receipt.date, displayedComponents: [.date, .hourAndMinute])
            }
            
            Section("备注") {
                TextEditor(text: $receipt.note)
                    .frame(minHeight: 100)
            }
            
            Section("照片") {
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
                
                Button("添加照片") {
                    showingImagePicker = true
                }
            }
        }
        .navigationTitle(receipt.id == UUID() ? "新建收据" : "编辑收据")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    if receipt.id == UUID() {
                        cardStore.addReceipt(receipt)
                    } else {
                        cardStore.updateReceipt(receipt)
                    }
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            CustomImagePicker(images: $receipt.images)
        }
    }
} 
