import SwiftUI
import AVFoundation
import Vision

struct PoseDetectorView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: WorkoutViewModel

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        var viewModel: WorkoutViewModel
        
        // Simple state machine for pushup detection
        var wasDown = false
        var wasUp = true
        
        init(viewModel: WorkoutViewModel) {
            self.viewModel = viewModel
        }

        func didDetectPose(points: [VNHumanBodyPoseObservation.JointName : CGPoint]) {
            // Basic pushup logic: Check relative vertical position of shoulders vs elbows
            // Note: This is a simplified heuristic. Real implementation needs more robust geometry.
            
            guard let leftShoulder = points[.leftShoulder],
                  let rightShoulder = points[.rightShoulder],
                  let leftElbow = points[.leftElbow],
                  let rightElbow = points[.rightElbow] else { return }
            
            // Average Y positions (normalized 0..1, 0 is bottom in Vision usually, but check orientation)
            // In Vision normalized coords, (0,0) is bottom-left.
            
            let avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2
            let avgElbowY = (leftElbow.y + rightElbow.y) / 2
            
            // "Down" position: Shoulders are close to or below elbows (visually lower on screen, so higher Y in some coords, lower in others depending on orientation)
            // Let's assume standard portrait: (0,0) bottom-left.
            // Up: Shoulders significantly above elbows (higher Y).
            // Down: Shoulders close to elbows (similar Y).
            
            let threshold: CGFloat = 0.1 // Adjust based on testing
            
            let isDown = (avgShoulderY - avgElbowY) < threshold
            
            if isDown {
                if !wasDown {
                    wasDown = true
                    wasUp = false
                }
            } else {
                // Is Up
                if wasDown && !wasUp {
                    // Completed a rep
                    DispatchQueue.main.async {
                        self.viewModel.incrementReps()
                    }
                    wasUp = true
                    wasDown = false
                }
            }
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didDetectPose(points: [VNHumanBodyPoseObservation.JointName : CGPoint])
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: CameraViewControllerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            if captureSession.canAddOutput(videoOutput) {
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                captureSession.addOutput(videoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            guard let observation = request.results?.first as? VNHumanBodyPoseObservation else { return }
            
            // Extract points
            guard let recognizedPoints = try? observation.recognizedPoints(.all) else { return }
            
            // Convert to simple dictionary for delegate
            var points: [VNHumanBodyPoseObservation.JointName : CGPoint] =[:]
            
            let keys: [VNHumanBodyPoseObservation.JointName] = [.leftShoulder, .rightShoulder, .leftElbow, .rightElbow]
            
            for key in keys {
                if let point = recognizedPoints[key], point.confidence > 0.3 {
                    points[key] = point.location
                }
            }
            
            self?.delegate?.didDetectPose(points: points)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:]).perform([request])
    }
}
