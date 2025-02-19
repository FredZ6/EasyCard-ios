import SwiftUI

struct ImagePreviewView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .alert("Delete Photo", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    isPresented = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this photo?")
            }
        }
    }
} 