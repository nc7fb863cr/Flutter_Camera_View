import Flutter
import UIKit
import Photos

class CameraView: NSObject, FlutterPlatformView {
    @IBOutlet var _view: UIView!
    let cameraController = CameraController()
    var channel: FlutterMethodChannel
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ){
        _view = UIView()
        channel = FlutterMethodChannel(name: Constants.pluginName, binaryMessenger: messenger!)
        super.init()
    }
    
    func view() -> UIView {
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch (call.method){
                
            case Constants.setDimension:
                self?.setViewDimension(call.arguments)
                
            case Constants.switchCamera:
                let cameraPosition = self?.switchCamera()
                result(cameraPosition)
                
            case Constants.takePhoto:
                self?.takePhoto(result: result)
                
            case Constants.canToggleFlash:
                self?.canToggleFlash(result: result)
                
            case Constants.toggleFlash:
                self?.toggleFlash(result: result)
                
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        
        return _view
    }
    
    func createNativeView(view _view: UIView, withFrame frame: CGRect){
        _view.backgroundColor = .black
        _view.frame = frame
        
        cameraController.prepare { [unowned self] (error) in
            if let error = error { print(error) }
            try? self.cameraController.displayPreview(on: _view, withFrame: frame)
        }
    }
    
    func setViewDimension(_ args: Any?){
        let arguments = args as! Dictionary<String, Double>
        let frame = CGRect(x: 0, y: 0, width: arguments["width"] ?? 0, height: arguments["height"] ?? 0)
        createNativeView(view: _view, withFrame: frame)
    }
    
    func switchCamera() -> String {
        do { try cameraController.switchCameras() }
        catch {
            print(error)
            return "error"
        }
        
        switch cameraController.currentCameraPosition {
            // .some 表示 optional enum 有資料
        case .some(.front):
            return "front"
        case .some(.rear):
            return "rear"
        case .none:
            return "none"
        }
    }
    
    func takePhoto(result: @escaping FlutterResult) {
        cameraController.captureImage { ( image, error, data ) in
            guard let image = image, let data = data else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            
            result(FlutterStandardTypedData(bytes: data))
        }
    }
    
    func canToggleFlash(result: @escaping FlutterResult){
        if let cameraPosition = cameraController.currentCameraPosition {
            result(cameraPosition == .rear)
        } else {
            result(Bool(false))
        }
    }
    
    func toggleFlash(result: @escaping FlutterResult) {
        guard cameraController.currentCameraPosition != nil && cameraController.currentCameraPosition == .rear else { return }
        
        do {
            try cameraController.rearCamera?.lockForConfiguration()
            cameraController.flashMode = cameraController.flashMode == .on ? .off : .on
            cameraController.rearCamera?.torchMode = cameraController.flashMode == .on ? .on : .off
            cameraController.rearCamera?.unlockForConfiguration()
            result(Bool(cameraController.flashMode == .on))
        }
        
        catch {
            print("Unable to toggle flashlight")
        }
    }
}
