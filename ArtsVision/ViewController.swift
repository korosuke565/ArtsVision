import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    
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
    
    //バタンイベント
    func onClickMyButton(sender: UIButton) {
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

















