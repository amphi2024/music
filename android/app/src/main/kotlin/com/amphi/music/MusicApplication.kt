package com.amphi.music

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MusicApplication : Application() {

    companion object {
        const val MUSIC_NOTIFICATION_CHANNEL_ID = "music_channel"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if(Build.VERSION.SDK_INT >= 26) {
            val channelName = "Music Notifications" // Name of the channel
            val channelDescription = "Notifications for music playback" // Description of the channel
            val importance = NotificationManager.IMPORTANCE_LOW // Set notification importance

            val channel = NotificationChannel(
                MUSIC_NOTIFICATION_CHANNEL_ID, // The channel ID
                channelName,                    // The channel name
                importance                      // Importance level
            ).apply {
                description = channelDescription
            }

            // Get the NotificationManager system service
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }

}