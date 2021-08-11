package com.example.plugin

import android.content.Context
import android.util.Log
import android.view.View
import androidx.annotation.NonNull
import androidx.constraintlayout.widget.ConstraintLayout
import com.pedro.rtplibrary.view.OpenGlView
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
import java.lang.Exception

/** Plugin */
class Plugin: FlutterPlugin{
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    /*channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin")
    channel.setMethodCallHandler(this)*/

    flutterPluginBinding
     .platformViewRegistry
     .registerViewFactory("<platform-view-type>", NativeViewFactory(flutterPluginBinding.binaryMessenger))
  }

  /*override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    if (call.method == "startStreaming") {
      Log.e("method start streaming", "called")

    }
    else {
      result.notImplemented()
    }
  }*/

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

  private var channel : MethodChannel = MethodChannel(messenger, "plugin")

  private var view: LiveStreamView
  private var apiVideo: ApiVideoLiveStream
  private var livestreamKey: String = ""
  private var url : String? = null
  private var methodChannel: MethodChannel? = null

  override fun getView(): View {
    return view.findViewById(R.id.opengl_view)
  }
  override fun dispose() {
    try {
      methodChannel?.setMethodCallHandler(null)
    }catch (e: Exception){
      Log.e("MethodCallHandler","Already null")
    }
  }

  init {
    channel.setMethodCallHandler(this)
    view = LiveStreamView(context)
    val openGlView = view.findViewById<OpenGlView>(R.id.opengl_view)
    apiVideo = ApiVideoLiveStream(context, this, null, null)
    initMethodChannel(messenger, id);
  }

  private fun initMethodChannel(messenger: BinaryMessenger, viewId: Int){
    methodChannel = MethodChannel(messenger, "plugin_$viewId")
    methodChannel!!.setMethodCallHandler(this)
  }

  override fun onConnectionSuccessRtmp() {
    Log.i("Rtmp Connection", "success")
  }

  override fun onConnectionFailedRtmp(reason: String?) {
    Log.e("Rtmp Connection", "failed")
  }

  override fun onNewBitrateRtmp(bitrate: Long) {
    Log.i("New rtmp bitrate", "$bitrate")
  }

  override fun onDisconnectRtmp() {
    Log.i("Rtmp connetion", "On disconnect")
  }

  override fun onAuthErrorRtmp() {
    Log.e("Rtmp Auth", "error")
  }

  override fun onAuthSuccessRtmp() {
    Log.i("Rtmp Auth", "success")
  }

  private fun setUrl(newUrl: String?){
    url = if(url != null || url != ""){
      newUrl
    }else{
      null
    }

  }

  private fun startLive(){
    Log.e("startlive method","called")
    apiVideo.startStreaming(livestreamKey, url)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method){
      "setLivestreamKey" -> livestreamKey = call.arguments.toString()
      "startStreaming" -> startLive()
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