import Foundation
import TensorSwift

class TFDetecotor {
    static let instance = TFDetecotor()
    
    private let classifier = Classifier(path: Bundle.main.resourcePath!)
    
    private init() {
    }
    
    func detectImage(image: UIImage, inputSize: Int) -> Int {
        let input: Tensor
        
        
        do {
            var pixels = [UInt8](repeating: 0, count: inputSize * inputSize * 4)
            
            
            let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
            
            
            let context = CGContext(data: &pixels, width: inputSize, height: inputSize, bitsPerComponent: 8, bytesPerRow: inputSize * 3, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)!
            
            let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(inputSize), height: CGFloat(inputSize))
            
            context.clear(rect)
            context.draw(context as! CGImage, in: rect, byTiling: false)
            
            
            
            let rgb = pixels.enumerated().filter { $0.0 % 4 != 3 }.map { Float($0.1) / 255.0 }
            
            input = Tensor(shape: [Dimension(inputSize), Dimension(inputSize), Dimension(3)], elements: rgb)
        }
        
        return classifier.classify(x_image: input)
    }
}
