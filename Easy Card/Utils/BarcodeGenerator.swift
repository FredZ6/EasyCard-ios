import UIKit
import CoreImage

struct BarcodeGenerator {
    static func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(10.0, forKey: "inputQuietSpace")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext()
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        
        return UIImage(cgImage: cgImage!)
    }
} 