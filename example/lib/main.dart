import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plugin/plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Plugin? controller;
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // platformVersion = await Plugin.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Center(
                child: _cameraPreviewWidget(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: style,
                    onPressed: null,
                    child: const Text('Disabled'),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: style,
                    onPressed: () {
                      Plugin.startStream();
                    },
                    child: const Text('Start'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    final plugin = Plugin();

    return Container(
      color: Colors.lightBlueAccent,
      child: LiveStreamPreview(
        controller: plugin,
        liveStreamKey: 'd08c582e-e251-4f9e-9894-8c8d69755d45',
        videoResolution: '2160p',
      ),
    );
  }
}
