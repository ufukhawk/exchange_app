import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var blurView: UIVisualEffectView?
  private var screenCaptureEventHandler: ScreenCaptureEventHandler?
  private var screenshotEventHandler: ScreenshotEventHandler?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let screenshotChannel = FlutterMethodChannel(
      name: "screenshot_protection",
      binaryMessenger: controller.binaryMessenger
    )
    
    screenshotChannel.setMethodCallHandler({ [weak self] (call, result) in
      switch call.method {
      case "enableProtection":
        // No longer needed
        result(nil)
      case "disableProtection":
        // No longer needed
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    // Screenshot Detection Event Channel
    screenshotEventHandler = ScreenshotEventHandler()
    let screenshotEventChannel = FlutterEventChannel(
      name: "screenshot_detection",
      binaryMessenger: controller.binaryMessenger
    )
    screenshotEventChannel.setStreamHandler(screenshotEventHandler)
    
    // Screen Recording Detection Event Channel (iOS 11+)
    if #available(iOS 11.0, *) {
      screenCaptureEventHandler = ScreenCaptureEventHandler()
      let captureEventChannel = FlutterEventChannel(
        name: "screen_capture_detection",
        binaryMessenger: controller.binaryMessenger
      )
      captureEventChannel.setStreamHandler(screenCaptureEventHandler)
    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @objc private func appWillResignActive() {
    // Özellik 1: App arkaplana atıldığında blur ekle
    let blurEffect = UIBlurEffect(style: .light)
    blurView = UIVisualEffectView(effect: blurEffect)
    blurView?.frame = window?.frame ?? .zero
    blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window?.addSubview(blurView!)
  }
  
  @objc private func appDidBecomeActive() {
    // Blur'u kaldır
    blurView?.removeFromSuperview()
    blurView = nil
  }
  
  @objc private func didTakeScreenshot(_ notification: Notification) {
    // Özellik 2: Screenshot algılandığında Flutter'a bildir
    screenshotEventHandler?.sendScreenshotEvent()
  }
}

// Screenshot Detection Handler
class ScreenshotEventHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
  
  func sendScreenshotEvent() {
    eventSink?(true)
    print("📸 Screenshot detected!")
  }
}

// Screen Recording Detection Handler
@available(iOS 11.0, *)
class ScreenCaptureEventHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    
    // Send initial state
    events(UIScreen.main.isCaptured)
    
    // Özellik 3: Screen recording değişikliklerini dinle
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureDidChange),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    return nil
  }
  
  @objc private func screenCaptureDidChange() {
    let isCaptured = UIScreen.main.isCaptured
    eventSink?(isCaptured)
    print("📱 Screen recording status: \(isCaptured)")
  }
}
