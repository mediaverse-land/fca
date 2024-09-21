package com.app.mediaverse

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import android.util.DisplayMetrics
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.pedro.rtplibrary.rtmp.RtmpDisplay
import net.ossrs.rtmp.ConnectCheckerRtmp

class ScreenCaptureService : Service(), ConnectCheckerRtmp {

    private var mediaProjection: MediaProjection? = null
    private lateinit var rtmpDisplay: RtmpDisplay
    private var rtmpUrl: String? = null

    companion object {
        private const val CHANNEL_ID = "ScreenCaptureServiceChannel"
        private const val NOTIFICATION_ID = 1
        const val RESULT_OK = -1  // Instead of referencing Activity.RESULT_OK, use RESULT_OK directly
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }



    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Media Projection Service Active")
            .setContentText("Capturing your screen...")
            .setSmallIcon(android.R.drawable.ic_media_play)  // Use a valid drawable
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        // Start the service as a foreground service
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Get the RTMP URL and MediaProjection data from the intent
        rtmpUrl = intent?.getStringExtra("RTMP_URL")
        val resultCode = intent?.getIntExtra("RESULT_CODE", RESULT_OK) ?: return START_NOT_STICKY
        val data = intent?.getParcelableExtra<Intent>("DATA") ?: return START_NOT_STICKY

        val mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, data)

        // Start RTMP streaming
        startStreaming()

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopScreenCapture()
        stopForeground(true)
    }

    // Method to create a foreground notification
    private fun createForegroundNotification(): Notification {
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Screen Capture Service")
            .setContentText("Capturing your screen...")
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)

        return notificationBuilder.build()
    }

    // Create notification channel for Android O and higher
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Media Projection Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun startStreaming() {
        if (mediaProjection != null && rtmpUrl != null) {
            rtmpDisplay = RtmpDisplay(this, true, this)
            rtmpDisplay.setIntentResult(RESULT_OK, Intent())  // Pass the mediaProjection data

            // Prepare screen capture parameters
            val metrics = DisplayMetrics()
            (getSystemService(Context.WINDOW_SERVICE) as android.view.WindowManager).defaultDisplay.getMetrics(metrics)

            // Prepare video and start stream
            if (rtmpDisplay.prepareAudio() && rtmpDisplay.prepareVideo(
                    metrics.widthPixels, metrics.heightPixels, 30, 3000 * 1024, 0, 320
                )
            ) {
                rtmpDisplay.startStream(rtmpUrl)
                Toast.makeText(this, "Streaming to $rtmpUrl", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Error preparing stream", Toast.LENGTH_SHORT).show()
            }
        } else {
            Toast.makeText(this, "MediaProjection or RTMP URL is null", Toast.LENGTH_SHORT).show()
        }
    }

    // Stop RTMP streaming
    private fun stopScreenCapture() {
        if (::rtmpDisplay.isInitialized && rtmpDisplay.isStreaming) {
            rtmpDisplay.stopStream()
            Toast.makeText(this, "Stream stopped", Toast.LENGTH_SHORT).show()
        }
        mediaProjection?.stop()
        mediaProjection = null
    }

    // RTMP connection callbacks
    override fun onConnectionSuccessRtmp() {
        Toast.makeText(this, "Connection Success", Toast.LENGTH_SHORT).show()
    }

    override fun onConnectionFailedRtmp(reason: String) {
        Toast.makeText(this, "Connection Failed: $reason", Toast.LENGTH_SHORT).show()
        stopScreenCapture()
    }

    override fun onDisconnectRtmp() {
        Toast.makeText(this, "Disconnected", Toast.LENGTH_SHORT).show()
        stopScreenCapture()
    }

    override fun onAuthErrorRtmp() {
        Toast.makeText(this, "Auth Error", Toast.LENGTH_SHORT).show()
        stopScreenCapture()
    }

    override fun onAuthSuccessRtmp() {
        Toast.makeText(this, "Auth Success", Toast.LENGTH_SHORT).show()
    }

    override fun onNewBitrateRtmp(bitrate: Long) {
        // Optionally handle bitrate updates
    }
}
