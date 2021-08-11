package com.example.plugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

class Plugin: FlutterPlugin{
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding
     .platformViewRegistry
     .registerViewFactory("<platform-view-type>", NativeViewFactory(flutterPluginBinding.binaryMessenger))
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}