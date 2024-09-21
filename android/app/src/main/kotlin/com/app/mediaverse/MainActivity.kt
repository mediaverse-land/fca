package com.app.mediaverse

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val REQUEST_CODE_CAPTURE_PERMISSION = 1001
    private lateinit var mediaProjectionManager: MediaProjectionManager
    private var rtmpUrl: String? = null

    private val CHANNEL = "com.app.mediaverse/rtmp"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create the MethodChannel to communicate with Flutter
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Set up method call handler for start and stop screen sharing
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startScreenShare" -> {
                    rtmpUrl = call.argument<String>("rtmpUrl")
                    if (rtmpUrl != null) {
                        // Request screen capture permission
                        requestScreenCapturePermission()
                        result.success("Screen capture permission requested")
                    } else {
                        result.error("INVALID_ARGUMENT", "RTMP URL is required", null)
                    }
                }
                "stopScreenShare" -> {
                    // Stop the screen capture service
                    stopScreenCaptureService()
                    result.success("Screen sharing stopped")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestScreenCapturePermission() {
        mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val captureIntent = mediaProjectionManager.createScreenCaptureIntent()
        startActivityForResult(captureIntent, REQUEST_CODE_CAPTURE_PERMISSION)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_CAPTURE_PERMISSION && resultCode == Activity.RESULT_OK) {
            // Permission granted for media projection
            val intent = Intent(this, ScreenCaptureService::class.java)
            intent.putExtra("EXTRA_DATA", data)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        } else {
            // Handle permission denial
        }
    }


    private fun startScreenCaptureService(resultCode: Int, data: Intent) {
        val serviceIntent = Intent(this, ScreenCaptureService::class.java)
        serviceIntent.putExtra("RTMP_URL", rtmpUrl)  // Pass RTMP URL to the service
        serviceIntent.putExtra("RESULT_CODE", resultCode)
        serviceIntent.putExtra("DATA", data)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)  // Start the foreground service
        } else {
            startService(serviceIntent)
        }
        Toast.makeText(this, "Screen sharing started", Toast.LENGTH_SHORT).show()
    }

    private fun stopScreenCaptureService() {
        val serviceIntent = Intent(this, ScreenCaptureService::class.java)
        stopService(serviceIntent)
        Toast.makeText(this, "Screen sharing stopped", Toast.LENGTH_SHORT).show()
    }
}
