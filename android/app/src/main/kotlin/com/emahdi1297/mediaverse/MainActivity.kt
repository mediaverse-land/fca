package com.emahdi1297.mediaverse

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val REQUEST_CODE_SCREEN_CAPTURE = 1000
    private val RECORD_AUDIO_REQUEST_CODE = 123
    private var rtmpUrl: String? = null
    private val CHANNEL = "com.mediaverse.mediaverse/rtmp"

    private lateinit var methodChannel: MethodChannel
    private lateinit var mediaProjectionManager: MediaProjectionManager
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->
            if (call.method == "startScreenShare") {
                rtmpUrl = call.argument<String>("rtmpUrl")
                    if (rtmpUrl != null) {
                        startScreenCapture()
                        result.success("Screen sharing started")
                    } else {
                        result.error("INVALID_ARGUMENT", "RTMP URL is required", null)
                    }
            } if (call.method == "stopScreenShare") {
            stopScreenCapture()
                   result.success("Screen sharing stopped")
            } else {
                result.notImplemented()
            }
        }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
    }

    private fun startScreenCapture() {
        val captureIntent = mediaProjectionManager.createScreenCaptureIntent()
        startActivityForResult(captureIntent, REQUEST_CODE_SCREEN_CAPTURE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_SCREEN_CAPTURE && resultCode == RESULT_OK && data != null) {
            val serviceIntent = Intent(this, ScreenCaptureService::class.java)
            serviceIntent.putExtra("resultCode", resultCode)
            serviceIntent.putExtra("data", data)
            serviceIntent.putExtra("rtmpUrl", rtmpUrl)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ContextCompat.startForegroundService(this, serviceIntent)
            } else {
                startService(serviceIntent)
            }
        } else {
            Toast.makeText(this, "Screen Cast Permission Denied", Toast.LENGTH_SHORT).show()
        }
    }

    private fun stopScreenCapture() {
        val serviceIntent = Intent(this, ScreenCaptureService::class.java)
        stopService(serviceIntent)
        methodChannel.invokeMethod("stopTheStream", null)
    }

    override fun onDestroy() {
        super.onDestroy()
        stopScreenCapture()
    }
}
