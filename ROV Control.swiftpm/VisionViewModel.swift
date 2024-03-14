import SwiftUI
import Vision
import CoreML
struct Detection {
    let box:CGRect
    let confidence:Float
    let label:String?
    let color:UIColor
}

enum ProcessingState {
    case processing
    case idle
    case waiting
}
@Observable
class VisionViewModel{
    
    var detectionOverlay = Color.clear
    var processingState : ProcessingState = .waiting
    var requests = [VNCoreMLRequest]()
    var imageToProcess : UIImage? = nil
    var result : UIImage? = nil
    
    func setupObjectDetectionModel(_ modelURL : URL) -> Bool{
        do {
            let compiledURL = try MLModel.compileModel(at: modelURL)
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: compiledURL))
            
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async {
                    if let observations = request.results {
                        var detection = [Detection]()
                        for observation in observations where observation is VNRecognizedObjectObservation {
                            if let objectObservation = observation as? VNRecognizedObjectObservation {
                                let topLabelObservation = objectObservation.labels[0]
                                let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(self.imageToProcess!.size.width), Int(self.imageToProcess!.size.height))
                                let d = Detection(box: objectBounds, confidence: topLabelObservation.confidence, label: topLabelObservation.identifier, color: .orange.withAlphaComponent(0.5))
                                detection.append(d)
                            }
                        }
                        print("Result",detection.count)
                        self.result = self.drawDetectionsOnImage(detection, self.imageToProcess!)
                    }
                    self.processingState = .idle
                }
                
                
            })
            DispatchQueue.main.async {
                self.processingState = .idle
                self.requests = [objectRecognition]
            }
            
            return true
        } catch{
            print("Model loading went wrong: \(error)")
            
        }
        return false
    }
    func drawDetectionsOnImage(_ detections: [Detection], _ image: UIImage) -> UIImage? {
        let imageSize = image.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let drawnImage = renderer.image(actions: { ctx in
            for detection in detections {
                if let labelText = detection.label {
                    let text = "\(labelText) : \(round(detection.confidence*100))"
                    let textRect  = CGRect(x: detection.box.minX + imageSize.width * 0.01, y: detection.box.minY + imageSize.width * 0.01, width: detection.box.width, height: detection.box.height)
                    text.draw(in: textRect)
                    ctx.cgContext.addRect(detection.box)
                    ctx.cgContext.setStrokeColor(detection.color.cgColor)
                    ctx.cgContext.setLineWidth(5.0)
                    ctx.cgContext.strokePath()
                    
                }
            }
            
        })
        
        return drawnImage
    }
    func processImage_YOLOv3(_ image : UIImage){
        if self.processingState == .idle{
            self.imageToProcess = image
            let handler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: .downMirrored)
            self.processingState = .processing
            DispatchQueue.global(qos: .userInitiated).async {
                do{
                    
                    try handler.perform(self.requests)
                }catch{
                    print("error \(error)")
                    self.processingState = .idle
                }
            }
            
        }
    }
}
