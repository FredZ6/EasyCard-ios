import UIKit
import CoreImage

struct BarcodeGenerator {
    static func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(10.0, forKey: "inputQuietSpace")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: [.useSoftwareRenderer: false])
        
        let scale: CGFloat = 10.0
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        
        UIGraphicsBeginImageContextWithOptions(uiImage.size, true, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: uiImage.size)).fill()
        
        uiImage.draw(in: CGRect(origin: .zero, size: uiImage.size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
} 