package com.amphi.music

import android.Manifest
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.os.IBinder
import android.support.v4.media.session.MediaSessionCompat
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class MusicService : Service() {
    private lateinit var mediaSession: MediaSessionCompat
    private lateinit var notificationManager: NotificationManagerCompat

    override fun onCreate() {
        super.onCreate()

        mediaSession = MediaSessionCompat(this, "MusicService")
        mediaSession.isActive = true

        notificationManager = NotificationManagerCompat.from(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Create and display a media notification
        showMediaNotification()

        // Handle playback logic (play, pause, etc.) here if needed

        return START_STICKY // Keep the service running until explicitly stopped
    }

    private fun showMediaNotification() {
        val playPauseIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, MediaButtonReceiver::class.java).apply {
                action = "PAUSE_ACTION"
            }, PendingIntent.FLAG_IMMUTABLE
        )

        // Create a media notification with action buttons
        val notificationBuilder = NotificationCompat.Builder(this, MusicApplication.MUSIC_NOTIFICATION_CHANNEL_ID)
            .setContentTitle("Song Title")
            .setContentText("Artist Name")
            .setSmallIcon(androidx.core.R.drawable.notification_bg)
           // .setLargeIcon(albumArtBitmap) // Optional: Use a bitmap for album art
//            .setStyle(NotificationCompat.MediaStyle()
//                .setMediaSession(mediaSession.sessionToken))
            .setOngoing(true) // Makes the notification persistent (non-dismissable)
            .addAction(NotificationCompat.Action(
                androidx.core.R.drawable.notification_bg, "Pause", playPauseIntent
            ))

        // Issue the notification

        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return
        }
        else {
            notificationManager.notify(1, notificationBuilder.build())
        }

    }

    override fun onDestroy() {
        super.onDestroy()

        mediaSession.release()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}