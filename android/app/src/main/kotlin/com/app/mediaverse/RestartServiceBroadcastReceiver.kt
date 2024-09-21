package com.example.test_service_f

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.preference.PreferenceManager  // Correct import for AndroidX preferences
import com.app.mediaverse.ScreenCaptureService  // Ensure this import is correct for your ScreenCaptureService

class RestartServiceBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context != null && intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            // Retrieve stored preferences to check if the service should restart
            val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
            val shouldRestartService = sharedPreferences.getBoolean("SERVICE_ENABLED", false)

            if (shouldRestartService) {
                // Restart the ScreenCaptureService
                val serviceIntent = Intent(context, ScreenCaptureService::class.java)
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)  // For Android O and above
                } else {
                    context.startService(serviceIntent)  // For Android versions below O
                }
            }
        }
    }
}
