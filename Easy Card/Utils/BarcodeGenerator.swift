import UIKit
import CoreImage

struct BarcodeGenerator {
    static func generateBarcode(from string: String) -> UIImage? {
        // 移除所有空格
        let cleanString = string.replacingOccurrences(of: " ", with: "")
        
        // 首先尝试 EAN-13 格式（如果输入是13位数字）
        if cleanString.count == 13 && cleanString.allSatisfy({ $0.isNumber }) {
            if let ean13Image = generateEAN13(from: cleanString) {
                return ean13Image
            }
        }
        
        // 如果不是EAN-13，则使用Code 128（支持所有ASCII字符）
        return generateCode128(from: cleanString)
    }
    
    private static func generateEAN13(from string: String) -> UIImage? {
        guard let data = string.data(using: .ascii),
              let filter = CIFilter(name: "CIEan13BarcodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(NSNumber(value: 0), forKey: "inputQuietSpace")
        
        return processFilterOutput(filter)
    }
    
    private static func generateCode128(from string: String) -> UIImage? {
        guard let data = string.data(using: .ascii),
              let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(NSNumber(value: 0), forKey: "inputQuietSpace")
        
        return processFilterOutput(filter)
    }
    
    private static func processFilterOutput(_ filter: CIFilter) -> UIImage? {
        guard let outputImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
} 