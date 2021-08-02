
import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Plugin {
  static const MethodChannel _channel =
      const MethodChannel('plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Widget buildPreview() {
    try {
      return CameraPlatform.instance.buildPreview(1);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }
}

class LiveStreamPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  const LiveStreamPreview(this.plugin, {this.child});

  /// The controller for the camera that the preview is shown for.
  final Plugin plugin;
  /// A widget to overlay on top of the camera preview
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      // return widget on Android.
      case TargetPlatform.iOS:
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }

}
