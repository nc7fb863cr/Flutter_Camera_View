import Flutter
import UIKit

public class SwiftNativeCameraPlugin: NSObject, FlutterPlugin {
    var factory: CameraViewFactory
    
    init(with registrar: FlutterPluginRegistrar) {
        self.factory = CameraViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: Constants.viewType)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.addApplicationDelegate(SwiftNativeCameraPlugin(with: registrar))
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
    }
}
