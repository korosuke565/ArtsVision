import UIKit

extension UIImage {

    //画質を担保したままResizeするクラスメソッド
    func ResizeUIImage(width: CGFloat, height: CGFloat) -> UIImage! {
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        var context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(x:0, y:0, width: size.width, height: size.height))
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func CGRectMake(_ x:CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
