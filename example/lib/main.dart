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
  Plugin? controller;

  @override
  void initState() {
    super.initState();
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
