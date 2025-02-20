import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var cardNumber: String
    @StateObject private var camera = CameraController()
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            // Scanning Frame
            VStack {
                // Top Bar with Cancel Button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Cancel")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(.black.opacity(0.6))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Scanning Frame (removed red line animation)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(height: 100)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            camera.start()
        }
        .onDisappear {
            camera.stop()
        }
        .onChange(of: camera.scannedCode) { _, newValue in
            if let code = newValue {
                cardNumber = code
                dismiss()
            }
        }
    }
}

// Camera Preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraController
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = camera.preview
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Camera Controller
class CameraController: NSObject, ObservableObject {
    @Published var scannedCode: String?
    @Published var scanningLineOffset: CGFloat = -50
    
    let preview = AVCaptureVideoPreviewLayer()
    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    override init() {
        super.init()
        setupCamera()
        // Scanning line animation
        withAnimation(.linear(duration: 1.5).repeatForever()) {
            scanningLineOffset = 50
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        session.addInput(input)
        session.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .code128]
        
        preview.session = session
        preview.videoGravity = .resizeAspectFill
    }
    
    func start() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func stop() {
        session.stopRunning()
    }
}

extension CameraController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, 
                       didOutput metadataObjects: [AVMetadataObject], 
                       from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            scannedCode = stringValue
        }
    }
} 