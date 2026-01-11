import Foundation
import UIKit

@available(iOS 11.0, *)
class ScreenCaptureDetector {
    private var flutterEventSink: FlutterEventSink?
    private var isMonitoring = false
    
    init() {
        setupNotifications()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func screenCaptureDidChange() {
        let isCaptured = UIScreen.main.isCaptured
        
        if let sink = flutterEventSink {
            sink(["isScreenRecording": isCaptured])
        }
        
        // Log for debugging
        print("📱 Screen recording status changed: \(isCaptured)")
    }
    
    func startMonitoring(eventSink: @escaping FlutterEventSink) {
        self.flutterEventSink = eventSink
        isMonitoring = true
        
        // Send initial state
        let isCaptured = UIScreen.main.isCaptured
        eventSink(["isScreenRecording": isCaptured])
        
        print("📱 Screen capture monitoring started. Initial state: \(isCaptured)")
    }
    
    func stopMonitoring() {
        isMonitoring = false
        flutterEventSink = nil
        print("📱 Screen capture monitoring stopped")
    }
    
    func getCurrentState() -> Bool {
        return UIScreen.main.isCaptured
    }
}

// Event Channel Handler
@available(iOS 11.0, *)
class ScreenCaptureEventHandler: NSObject, FlutterStreamHandler {
    private var detector: ScreenCaptureDetector?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        detector = ScreenCaptureDetector()
        detector?.startMonitoring(eventSink: events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        detector?.stopMonitoring()
        detector = nil
        return nil
    }
}

