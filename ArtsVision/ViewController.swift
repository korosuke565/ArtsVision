import UIKit
import AVFoundation
import TensorSwift


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let inputSize = 56
    private let classifier = Classifier(path: Bundle.main.resourcePath!)
    
    let myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
    
    // セッション
    var mySession : AVCaptureSession!
    // カメラデバイス
    var myDevice : AVCaptureDevice!
    // 出力先
    var myOutput : AVCaptureVideoDataOutput!
    // バックカメラからVideoInputを取得
    var myInput : AVCaptureDeviceInput!
    
    // 画像のアウトプット.
    var myImageOutput: AVCaptureStillImageOutput!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // カメラを準備
        if initCamera() {
            //撮影開始
            mySession.startRunning()
        }
        setButton()
    }
    
    // カメラの準備処理
    func initCamera() -> Bool {
        //セッションの作成
        mySession = AVCaptureSession()
        //解像度の指定
        mySession.sessionPreset = AVCaptureSessionPresetMedium
        
        //デバイス一覧の取得
        let devices = AVCaptureDevice.devices()
        
        for device in devices! {
            if((device as AnyObject).position == AVCaptureDevicePosition.back){
                myDevice = device as! AVCaptureDevice
            }
        }
        if myDevice == nil {
            return false
        }
        
        do {
            myInput = try AVCaptureDeviceInput(device: myDevice) as AVCaptureDeviceInput
        } catch let error {
            print(error)
        }
        
        // セッションに追加.
        if mySession.canAddInput(myInput) {
            mySession.addInput(myInput)
        } else {
            return false
        }
        
        // 出力先を生成(後で消す)
        myImageOutput = AVCaptureStillImageOutput()
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        
        // 出力先を設定
        myOutput = AVCaptureVideoDataOutput()
        myOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA) ]
        
        // FPSを設定
        do {
            try myDevice.lockForConfiguration()
            myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            //            myDevice.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            myDevice.unlockForConfiguration()
        } catch let error {
            print("lock error: \(error)")
            return false
        }
        
        //デリゲートを設定
        let queue = DispatchQueue(label: "myqueue")
        myOutput.setSampleBufferDelegate(self, queue: queue)
        
        // 遅れてきたフレームは無視する
        myOutput.alwaysDiscardsLateVideoFrames = true
        
        // セッションに追加.
        if mySession.canAddOutput(myOutput) {
            mySession.addOutput(myOutput)
        } else {
            return false
        }
        
        
        //カメラの向きを合わせる
        for connection in myOutput.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.isVideoOrientationSupported {
                    conn.videoOrientation = AVCaptureVideoOrientation.portrait
                }
            }
        }
        return true
    }
    
    
    //現在位置のカメラを探す
    func findCamera(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices() {
            if((device as AnyObject).position == position) {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }

    
    
    var inputImage : UIImage!
    //マイフレーム実行される処理
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        DispatchQueue.main.async {
            
            // UIImageへ変換
            self.inputImage = CameraUtil.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            // 表示
            self.imageView.image = CameraUtil.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        }
    }
    
    func setButton() {
        // UIボタンを作成
        myButton.backgroundColor = UIColor.red
        myButton.layer.masksToBounds = true
        myButton.setTitle("Classify", for: .normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - 50)
        myButton.addTarget(self, action: #selector(onClickMyButton),
                           for: .touchUpInside)
        
        //UIボタンをViewに追加
        self.view.addSubview(myButton);
    }
    
    func getArtInfo(number: Int) -> (title: String, name: String) {
        switch number {
        case 0:
            return ("『帽子をかぶった婦人』", "パブロ・ピカソ")
        case 1:
            return ("『王様の美術館』", "ルネ・マグリット")
        case 2:
            return ("『風神雷神図』", "福田美蘭")
        case 3:
            return ("『山水図』", "福田美蘭")
        case 4:
            return ("『ディストーション』", "アンドレ・ケルテス")
        case 5:
            return ("『海辺と太陽』", "岡本太郎")
        case 6:
            return ("『明日の神話』", "岡本太郎")
        case 7:
            return ("『縄文人』", "岡本太郎")
        case 8:
            return ("『ベラスケスによるインノケンティウス10世』", "フランシス・ベーコン")
        case 9:
            return ("『キリスト磔刑図のための3つの習作』", "フランシス・ベーコン")
        default:
            return ("『hoge』", "hoge")
        }
    
    
    }
    
    //ボタンイベント
    func onClickMyButton(sender: UIButton) {
        var input: Tensor
        var resizeImage: UIImage
        do {
            var image = inputImage
            
            resizeImage = (image?.ResizeUIImage(width: 56, height: 56))!
            
            let cgImage = image?.cgImage!
            var pixels = [UInt8](repeating: 0, count: inputSize * inputSize * 4)
            let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))
            let bitsPerComponent = 8
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let context2 = CGContext(data: &pixels, width: inputSize, height: inputSize, bitsPerComponent:
                bitsPerComponent, bytesPerRow: inputSize * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue);
            
            let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(inputSize), height: CGFloat(inputSize))
            context2?.clear(rect)
            context2?.draw(cgImage!, in: rect)
            
            let rgb = pixels.enumerated().filter { $0.0 % 3 != 3 }.map { Float($0.1) / 255.0 }

            input = Tensor(shape: [Dimension(inputSize), Dimension(inputSize),
                                   Dimension(3)], elements: rgb)
        }
        
        let estimatedLabel = classifier.classify(x_image: input)
        
        var artInfo = getArtInfo(number: estimatedLabel)
        
        let alert = UIAlertController(title: artInfo.title, message: artInfo.name, preferredStyle:
            UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

















