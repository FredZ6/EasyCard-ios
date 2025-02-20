import SwiftUI
import PhotosUI

// Move Coordinator to outside
final class ImagePickerCoordinator: NSObject, PHPickerViewControllerDelegate {
    private let images: Binding<[String]>
    private let dismiss: DismissAction
    
    init(images: Binding<[String]>, dismiss: DismissAction) {
        self.images = images
        self.dismiss = dismiss
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            // Create unique filename
                            let filename = UUID().uuidString + ".jpg"
                            // Get document directory path
                            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                let fileURL = path.appendingPathComponent(filename)
                                try? data.write(to: fileURL)
                                self.images.wrappedValue.append(fileURL.path)
                            }
                        }
                    }
                }
            }
        }
        dismiss()
    }
}

struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var images: [String]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0  // 0 means no limit
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(images: $images, dismiss: dismiss)
    }
} 