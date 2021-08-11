import Flutter
import UIKit
import LiveStreamIos
import AVFoundation

public class SwiftPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let factory = LiveStreamViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "<platform-view-type>")
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}

class LiveStreamViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return LiveStreamNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class LiveStreamNativeView: NSObject, FlutterPlatformView {
    private var _view: LiveStreamView
    private var channel: FlutterMethodChannel!

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = LiveStreamView()
        super.init()
        
        channel = FlutterMethodChannel(name: "plugin_\(viewId)", binaryMessenger: messenger!)
        channel.setMethodCallHandler { [weak self] (call, result) in
                    self?.handlerMethodCall(call, result)
                }
        
        // iOS views can be created here
        //createNativeView(view: _view)
    }

    func view() -> UIView {
        return _view
    }
    
    func handlerMethodCall(_ call: FlutterMethodCall, _ result: FlutterResult)  {
            switch call.method {
            case "startStreaming":
                _view.startStreaming()
                break
            case "stopStreamin":
                _view.stopStreaming()
                break
            case "setLivestreamKey":
                let key = call.arguments as! String
                print("key: \(key)")
                _view.liveStreamKey = key
            case "setParam":
                let data = call.arguments
                let jsonData = try? JSONSerialization.data(withJSONObject:data!)
                print("jsonData: \(String(describing: jsonData))")

            
            default:
                break
            }
        }

    func createNativeView(view _view: UIView){
        _view.backgroundColor = UIColor.blue
        let nativeLabel = UILabel()
        nativeLabel.text = "Native text from iOS"
        nativeLabel.textColor = UIColor.white
        nativeLabel.textAlignment = .center
        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
        _view.addSubview(nativeLabel)
    }
}

class LiveStreamView: UIView{
    private var apiVideo: ApiVideoLiveStream?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        apiVideo = ApiVideoLiveStream(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getResolutionFromString(resolutionString: String) -> ApiVideoLiveStream.Resolutions{
            switch resolutionString {
            case "240p":
                return ApiVideoLiveStream.Resolutions.RESOLUTION_240
            case "360p":
                return ApiVideoLiveStream.Resolutions.RESOLUTION_360
            case "480p":
                return ApiVideoLiveStream.Resolutions.RESOLUTION_480
            case "720p":
                return ApiVideoLiveStream.Resolutions.RESOLUTION_720
            case "1080p":
                return ApiVideoLiveStream.Resolutions.RESOLUTION_1080
            case "2160p":
                return ApiVideoLiveStream.Resolutions.RESOLUTION_2160
            default:
                return ApiVideoLiveStream.Resolutions.RESOLUTION_720
            }
        }
    
    @objc override func didMoveToWindow() {
            super.didMoveToWindow()
        }
        
        @objc var liveStreamKey: String = "" {
          didSet {
          }
        }
        
        @objc var rtmpServerUrl: String? {
          didSet {
          }
        }
        
        @objc var videoFps: Double = 30 {
          didSet {
            if(videoFps == Double(apiVideo!.videoFps)){
                return
            }
            apiVideo?.videoFps = videoFps
          }
        }
        
        @objc var videoResolution: String = "720p" {
          didSet {
            let newResolution = getResolutionFromString(resolutionString: videoResolution)
            if(newResolution == apiVideo!.videoResolution){
                return
            }
            apiVideo?.videoResolution = newResolution
          }
        }
        
        @objc var videoBitrate: Double = -1  {
          didSet {
          }
        }
        
        @objc var videoCamera: String = "back" {
          didSet {
            var value : AVCaptureDevice.Position
            switch videoCamera {
            case "back":
                value = AVCaptureDevice.Position.back
            case "front":
                value = AVCaptureDevice.Position.front
            default:
                value = AVCaptureDevice.Position.back
            }
            if(value == apiVideo?.videoCamera){
                return
            }
            apiVideo?.videoCamera = value
            
          }
        }
        
        @objc var videoOrientation: String = "landscape" {
          didSet {
            var value : ApiVideoLiveStream.Orientation
            switch videoOrientation {
            case "landscape":
                value = ApiVideoLiveStream.Orientation.landscape
            case "portrait":
                value = ApiVideoLiveStream.Orientation.portrait
            default:
                value = ApiVideoLiveStream.Orientation.landscape
            }
            if(value == apiVideo?.videoOrientation){
                return
            }
            apiVideo?.videoOrientation = value
            
          }
        }
        
        @objc var audioMuted: Bool = false {
          didSet {
            if(audioMuted == apiVideo!.audioMuted){
                return
            }
            apiVideo?.audioMuted = audioMuted
          }
        }
        
        @objc var audioBitrate: Double = -1 {
          didSet {
          }
        }
        
        @objc func startStreaming() {
            apiVideo!.startLiveStreamFlux(liveStreamKey: self.liveStreamKey, rtmpServerUrl: self.rtmpServerUrl)
        }
        
        @objc func stopStreaming() {
            apiVideo!.stopLiveStreamFlux()
        }
    
    
}
