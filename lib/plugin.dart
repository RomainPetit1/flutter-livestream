import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class Plugin {
  static const MethodChannel _channel = const MethodChannel('plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void startStream() async {
    await _channel.invokeMethod('startStreaming');
  }

  // Widget buildPreview() {
  //   try {
  //     return CameraPlatform.instance.buildPreview(1);
  //   } on PlatformException catch (e) {
  //     throw CameraException(e.code, e.message);
  //   }
  // }
}

class LiveStreamPreview extends StatefulWidget {
  final Plugin controller;
  final String liveStreamKey;
  final String? rtmpServerUrl;
  final double? videoFps;
  final String? videoResolution;
  final double? videoBitrate;
  final String? videoCamera;
  final String? videoOrientation;
  final bool? audioMuted;
  final double? audioBitrate;

  const LiveStreamPreview({
    required this.controller,
    required this.liveStreamKey,
    this.rtmpServerUrl,
    this.videoFps,
    this.videoResolution,
    this.videoBitrate,
    this.videoCamera,
    this.videoOrientation,
    this.audioMuted,
    this.audioBitrate,
  });

  @override
  _LiveStreamPreviewState createState() => _LiveStreamPreviewState();
}

class _LiveStreamPreviewState extends State<LiveStreamPreview> {
  late MethodChannel _channel;
  late Plugin _controller;
  Set _updateMap = {};

  createParams() {
    return {
      'liveStreamKey': widget.liveStreamKey,
      'rtmpServerUrl': widget.rtmpServerUrl,
      'videoFps': widget.videoFps,
      'videoResolution': widget.videoResolution,
      'videoBitrate': widget.videoBitrate,
      'videoCamera': widget.videoCamera,
      'videoOrientation': widget.videoOrientation,
      'audioMuted': widget.audioMuted,
      'audioBitrate': widget.audioBitrate
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    _controller = widget.controller;
    if (widget.liveStreamKey.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        _channel.invokeMethod('setLivestreamKey', widget.liveStreamKey);
      });
    }
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      _channel.invokeMethod('setParam', json.encode(createParams()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = '<plugin>';
    // Pass parameters to the platform side.

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // return widget on Android.
        return SizedBox(
          height: 400,
          child: AndroidView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: createParams(),
            onPlatformViewCreated: (viewId) {
              _channel = MethodChannel('plugin_$viewId');
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        );

      case TargetPlatform.iOS:
        return SizedBox(
          height: 400,
          child: UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: createParams(),
            onPlatformViewCreated: (viewId) {
              _channel = MethodChannel('plugin_$viewId');
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        );
      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }
}
