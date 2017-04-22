import Foundation
import TensorSwift

public struct Classifier {
    public let W_conv1: Tensor
    public let b_conv1: Tensor
    public let W_conv2: Tensor
    public let b_conv2: Tensor
    public let W_conv3: Tensor
    public let b_conv3: Tensor
    public let W_fc1: Tensor
    public let b_fc1: Tensor
    public let W_fc2: Tensor
    public let b_fc2: Tensor
    
    public func classify(x_image: Tensor) -> Int {
        let h_conv1 = (x_image.conv2d(filter: W_conv1, strides: [1, 1, 1]) + b_conv1).relu()
        let h_pool1 = h_conv1.maxPool(kernelSize: [2,2,1], strides: [2,2,1])
    
        let h_conv2 = (h_pool1.conv2d(filter: W_conv2, strides: [1,1,1]) + b_conv2).relu()
        let h_pool2 = h_conv2.maxPool(kernelSize: [2, 2, 1], strides: [2, 2, 1])
        
        let h_conv3 = (h_pool2.conv2d(filter: W_conv3, strides: [1,1,1]) + b_conv3).relu()
        let h_pool3 = h_conv3.maxPool(kernelSize: [2, 2, 1], strides: [2, 2, 1])
        
        let h_pool3_flat = h_pool3.reshaped([1, Dimension(7 * 7 * 128)])
        let h_fc1 = (h_pool3_flat.matmul(W_fc1) + b_fc1).relu()
        
        let y_conv = (h_fc1.matmul(W_fc2) + b_fc2).softmax()
        
        return y_conv.elements.enumerated().max { $0.1 < $1.1 }!.0
        
    
    }
}

extension Classifier {
    public init(path: String) {
        W_conv1 = Tensor(shape: [3, 3, 3, 32], elements: loadFloatArray(path, file: "W_conv1"))
        b_conv1 = Tensor(shape: [32], elements: loadFloatArray(path, file: "b_conv1"))
        
        W_conv2 = Tensor(shape: [3, 3, 3, 64], elements: loadFloatArray(path, file: "W_conv2"))
        b_conv2 = Tensor(shape: [64], elements: loadFloatArray(path, file: "b_conv2"))
        
        W_conv3 = Tensor(shape: [3, 3, 64, 128], elements: loadFloatArray(path, file: "W_conv3"))
        b_conv3 = Tensor(shape: [128], elements: loadFloatArray(path, file: "b_conv3"))
        
        W_fc1 = Tensor(shape: [Dimension(7 * 7 * 128), 1024], elements: loadFloatArray(path, file: "W_fc1"))
        
        b_fc1 = Tensor(shape: [1024], elements: loadFloatArray(path, file: "b_fc1"))
        W_fc2 = Tensor(shape: [1024, 10], elements: loadFloatArray(path, file: "W_fc2"))
        b_fc2 = Tensor(shape: [10], elements: loadFloatArray(path, file: "b_fc2"))

    }

}

private func loadFloatArray(_ directory: String, file: String) -> [Float] {
    
    let data = try! Data(contentsOf: URL(fileURLWithPath: (directory as
        NSString).appendingPathComponent(file)))

    return Array(UnsafeBufferPointer(start: UnsafeMutablePointer<Float>(mutating: (data as NSData).bytes.bindMemory(to: Float.self, capacity: data.count)), count: data.count / 4))
    
    
}

































