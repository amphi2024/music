package com.amphi.music

import android.Manifest
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaSession2Service.MediaNotification
import android.media.session.PlaybackState
import android.os.Binder
import android.os.IBinder
import android.support.v4.media.session.MediaSessionCompat
import androidx.annotation.OptIn
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.media.session.MediaButtonReceiver
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSession.Callback
import androidx.media3.session.MediaStyleNotificationHelper
import java.io.File

class MusicService : Service() {
    private lateinit var notificationManager: NotificationManagerCompat

    private val binder = LocalBinder()

    lateinit var player: ExoPlayer
    var isPlaying = false
    var title = ""
    var artist = ""
    var albumCoverFilePath: String? = null
    lateinit var mediaSession: MediaSession

    inner class LocalBinder : Binder() {
        fun getService(): MusicService = this@MusicService
    }

    override fun onCreate() {
        super.onCreate()

        notificationManager = NotificationManagerCompat.from(this)
        player = ExoPlayer.Builder(this).build()
        player.addListener(object : Player.Listener{
            override fun onPlaybackStateChanged(playbackState: Int) {
                super.onPlaybackStateChanged(playbackState)
                if(playbackState == PlaybackState.STATE_PAUSED) {
                    isPlaying = false
                }
                else {
                    isPlaying = true
                }
            }
        })
        mediaSession = MediaSession.Builder(this, player)
            .build()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Create and display a media notification
        showMediaNotification()

        // Handle playback logic (play, pause, etc.) here if needed

        return START_STICKY // Keep the service running until explicitly stopped
    }

    @OptIn(UnstableApi::class)
    fun showMediaNotification() {
        val playPauseIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, MediaButtonReceiver::class.java).apply {
                action = "PAUSE_ACTION"
            }, PendingIntent.FLAG_IMMUTABLE
        )

        // Create a media notification with action buttons

        val notificationBuilder = NotificationCompat.Builder(this, MusicApplication.MUSIC_NOTIFICATION_CHANNEL_ID)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentTitle(title)
            .setContentText(artist)
            .setSmallIcon(androidx.core.R.drawable.notification_bg)
            .addAction(NotificationCompat.Action(
                androidx.core.R.drawable.notification_bg, "Pause", playPauseIntent
            ))
            .addAction(NotificationCompat.Action(
                androidx.core.R.drawable.notification_bg, "Pause", playPauseIntent
            ))
            .addAction(NotificationCompat.Action(
                androidx.core.R.drawable.notification_bg, "Pause", playPauseIntent
            ))
            .setStyle(MediaStyleNotificationHelper.MediaStyle(mediaSession).setShowActionsInCompactView(1))
            .setOngoing(true)

             albumCoverFilePath?.let {
                 val file = File(it)
                 if(file.exists() && it.isNotEmpty()) {
                     val bitmap = BitmapFactory.decodeFile(albumCoverFilePath)
                     notificationBuilder.setLargeIcon(bitmap)
                 }
             }

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
        player.release()
        mediaSession.release()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return binder
    }
}