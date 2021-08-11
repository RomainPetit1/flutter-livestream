package com.example.plugin

import android.content.Context
import android.view.View
import androidx.annotation.NonNull
import androidx.constraintlayout.widget.ConstraintLayout
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.ossrs.rtmp.ConnectCheckerRtmp
import video.api.livestream_module.ApiVideoLiveStream

/** Plugin */
class Plugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    /*channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin")
    channel.setMethodCallHandler(this)*/

    flutterPluginBinding
     .platformViewRegistry
     .registerViewFactory("<plugin>", NativeViewFactory(flutterPluginBinding.binaryMessenger))
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    if (call.method == "startStreaming") {

    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

class LiveStreamView(context: Context): ConstraintLayout(context){
  init {
    inflate(context, R.layout.flutter_livestream, this)
  }
}

internal class LiveStreamNativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger):
  PlatformView, ConnectCheckerRtmp, MethodCallHandler {

  private var view: LiveStreamView? = null
  private var apiVideo: ApiVideoLiveStream
  private var livestreamKey: String = ""
  private var url : String? = null
  private var methodChannel: MethodChannel? = null

  override fun getView(): View {
    return view!!.findViewById(R.id.opengl_view)
  }
  override fun dispose() {
    TODO("Not yet implemented")
  }

  init {
    view = LiveStreamView(context)
    apiVideo = ApiVideoLiveStream(context, this, null, null)
    initMethodChannel(messenger, id);
  }

  private fun initMethodChannel(messenger: BinaryMessenger, viewId: Int){
    methodChannel = MethodChannel(messenger, "plugin_$viewId")
    methodChannel!!.setMethodCallHandler(this)
  }

  override fun onConnectionSuccessRtmp() {
    TODO("Not yet implemented")
  }

  override fun onConnectionFailedRtmp(reason: String?) {
    TODO("Not yet implemented")
  }

  override fun onNewBitrateRtmp(bitrate: Long) {
    TODO("Not yet implemented")
  }

  override fun onDisconnectRtmp() {
    TODO("Not yet implemented")
  }

  override fun onAuthErrorRtmp() {
    TODO("Not yet implemented")
  }

  override fun onAuthSuccessRtmp() {
    TODO("Not yet implemented")
  }

  private fun setUrl(newUrl: String?){
    url = if(url != null || url != ""){
      newUrl
    }else{
      null
    }

  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method){
      "setLivestreamKey" -> livestreamKey = call.arguments.toString()
      "startStreaming" -> apiVideo.startStreaming(livestreamKey, url)
    }
  }

}

class NativeViewFactory(private val messenger: BinaryMessenger): PlatformViewFactory(StandardMessageCodec.INSTANCE){
  private lateinit var mess : BinaryMessenger

  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val creationParams = args as Map<String?, Any?>?
    this.mess = messenger
    return LiveStreamNativeView(context, viewId, creationParams, this.mess)
  }
}