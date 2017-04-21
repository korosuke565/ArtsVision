import Foundation
import UIKit
import AVFoundation

class CameraUtil {
    // sampleBufferからUIImageへ変換
    class func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // ベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像データの情報を収集
        let baseAddress: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow: UInt = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width: UInt = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height: UInt = UInt(CVPixelBufferGetHeight(imageBuffer))
        
        // RGB色空間を作成
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Bimap graphic contextを作成
        let bitsPerCompornent: UInt = 8
        
        var bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        
        let newContext = CGContext(data: baseAddress, width: Int(width),
                                   height: Int(height), bitsPerComponent: Int(bitsPerCompornent),
                                   bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)! as CGContext
        
        // Quartz imageを作成
        let imageRef: CGImage = newContext.makeImage()!
        //UIImageを作成
        let resultImage: UIImage = UIImage(cgImage: imageRef)
        
        return resultImage
        
    }
}

