import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

class ScreenshotProtectionService {
  factory ScreenshotProtectionService() => _instance;

  ScreenshotProtectionService._internal();
  static final ScreenshotProtectionService _instance =
      ScreenshotProtectionService._internal();

  static const MethodChannel _channel =
      MethodChannel(AppConstants.screenshotProtectionChannel);
  static const EventChannel _eventChannel =
      EventChannel(AppConstants.screenshotDetectionChannel);
  static const EventChannel _screenCaptureEventChannel =
      EventChannel('screen_capture_detection');

  bool _isEnabled = false;
  bool _isScreenRecording = false;

  bool get isEnabled => _isEnabled;
  bool get isScreenRecording => _isScreenRecording;

  Future<bool> initialize() async {
    try {
      await enableProtection();
      _startScreenRecordingDetection();
      return true;
    } catch (e) {
      developer.log(
        'Failed to initialize screenshot protection',
        name: 'ScreenshotProtectionService',
        error: e,
      );
      return false;
    }
  }

  void _startScreenRecordingDetection() {
    _screenCaptureEventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        _isScreenRecording = event as bool;
        developer.log(
          'Screen recording status changed: $_isScreenRecording',
          name: 'ScreenshotProtectionService',
        );
      },
      onError: (dynamic error) {
        developer.log(
          'Error in screen recording detection: $error',
          name: 'ScreenshotProtectionService',
          error: error,
        );
      },
    );
  }

  Stream<bool> get onScreenRecordingStatusChanged {
    return _screenCaptureEventChannel.receiveBroadcastStream().map((event) {
      final isRecording = event as bool;
      developer.log(
        'Screen recording: $isRecording',
        name: 'ScreenshotProtectionService',
      );
      return isRecording;
    });
  }

  Future<void> enableProtection() async {
    if (_isEnabled) {
      return;
    }
    try {
      await _channel.invokeMethod('enableProtection');
      _isEnabled = true;
      developer.log(
        'Screenshot protection enabled',
        name: 'ScreenshotProtectionService',
      );
    } on PlatformException catch (e) {
      developer.log(
        'Failed to enable screenshot protection: ${e.message}',
        name: 'ScreenshotProtectionService',
        error: e,
      );
      _isEnabled = false;
    } on MissingPluginException {
      developer.log(
        'Screenshot protection not implemented for this platform',
        name: 'ScreenshotProtectionService',
      );
      _isEnabled = false;
    }
  }

  Future<void> disableProtection() async {
    if (!_isEnabled) {
      return;
    }
    try {
      await _channel.invokeMethod('disableProtection');
      _isEnabled = false;
      developer.log(
        'Screenshot protection disabled',
        name: 'ScreenshotProtectionService',
      );
    } on PlatformException catch (e) {
      developer.log(
        'Failed to disable screenshot protection: ${e.message}',
        name: 'ScreenshotProtectionService',
        error: e,
      );
    }
  }

  Stream<bool> get onScreenshotDetected {
    return _eventChannel.receiveBroadcastStream().map((event) {
      developer.log(
        'Screenshot detected: $event',
        name: 'ScreenshotProtectionService',
      );
      return event as bool;
    });
  }
}
