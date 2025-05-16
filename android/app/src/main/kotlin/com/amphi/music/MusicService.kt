package com.amphi.music

import android.Manifest
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Binder
import android.os.IBinder
import androidx.annotation.OptIn
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaStyleNotificationHelper
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MusicService : Service() {
    private lateinit var notificationManager: NotificationManagerCompat

    private val binder = LocalBinder()

    lateinit var player: ExoPlayer
    val list: MutableList<PlayableItem> = mutableListOf()
    var isPlaying = false
    var index = 0
    var playMode = 0
    var token = ""
    var title = ""
    var artist = ""
    var albumCoverFilePath: String? = null
    lateinit var mediaSession: MediaSession
    var methodChannel: MethodChannel? = null
    lateinit var notificationBuilder: NotificationCompat.Builder

    inner class LocalBinder : Binder() {
        fun getService(): MusicService = this@MusicService
    }


    @OptIn(UnstableApi::class)
    override fun onCreate() {
        super.onCreate()

        notificationManager = NotificationManagerCompat.from(this)
        player = ExoPlayer.Builder(this).build()
        mediaSession = MediaSession.Builder(this, player)
            .build()

        player.addListener(object : Player.Listener{
            override fun onPlaybackStateChanged(playbackState: Int) {
                if (playbackState == Player.STATE_ENDED) {
                    methodChannel?.invokeMethod("play_next", null)
                }
            }
        })

        val previousIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, com.amphi.music.MediaButtonReceiver::class.java).apply {
                action = "PLAY_PREVIOUS"
            }, PendingIntent.FLAG_IMMUTABLE
        )
        val nextIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, com.amphi.music.MediaButtonReceiver::class.java).apply {
                action = "PLAY_NEXT"
            }, PendingIntent.FLAG_IMMUTABLE
        )
        val playPauseIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, com.amphi.music.MediaButtonReceiver::class.java).apply {
                action = "PAUSE"
            }, PendingIntent.FLAG_IMMUTABLE
        )

        notificationBuilder = NotificationCompat.Builder(this, MusicApplication.MUSIC_NOTIFICATION_CHANNEL_ID)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentTitle(title)
            .setContentText(artist)
            .setSmallIcon(R.drawable.logo)
            .addAction(NotificationCompat.Action(R.drawable.previous, "Previous", previousIntent
            ))
            .addAction(NotificationCompat.Action( if(isPlaying) R.drawable.pause else R.drawable.play, "Pause", playPauseIntent
            ))
            .addAction(NotificationCompat.Action(R.drawable.next, "Pause", nextIntent
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

        startForeground(1, notificationBuilder.build())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            when (it.action) {
                "PLAY_PREVIOUS" -> {
                    if(player.currentPosition > 1500) {
                        player.seekTo(0)
                    }
                    else {
                        //methodChannel?.invokeMethod("play_previous", null)
                        playPrevious()
                    }
                }
                "PLAY_NEXT" -> {
                    playNext()
                    //methodChannel?.invokeMethod("play_next", null)
                }
                "PAUSE" -> {
                    if(isPlaying) {
                        isPlaying = false
                        player.pause()
                        methodChannel?.invokeMethod("on_pause", null)
                    }
                    else {
                        isPlaying = true
                        player.play()
                        methodChannel?.invokeMethod("on_resume", null)
                    }
                }
                else -> {}
            }
        }
        updateNotification()
        return START_STICKY
    }

    @OptIn(UnstableApi::class)
    fun setSource(url: String, filePath: String, playNow: Boolean = true) {
        val file = File(filePath)
        if(file.exists()) {
            val uri = Uri.fromFile(file)
            val mediaItem = MediaItem.fromUri(uri)
            player.setMediaItem(mediaItem)
        }
        else {
            val mediaItem = MediaItem.fromUri(Uri.parse(url))

            val dataSourceFactory = DefaultHttpDataSource.Factory()
                .setDefaultRequestProperties(
                    mapOf("Authorization" to token)
                )

            val mediaSource = ProgressiveMediaSource.Factory(dataSourceFactory)
                .createMediaSource(mediaItem)
            player.setMediaSource(mediaSource)
        }

        player.prepare()
        if(playNow) {
            player.play()
            isPlaying = true
        }
        else {
            isPlaying = false
        }
    }

    private fun playPrevious() {
        index--
        if(index < 0) {
            index = list.lastIndex
        }
        val item = list[index]
        title = item.title
        artist = item.artist
        albumCoverFilePath = item.albumCoverFilePath

        setSource(url = item.url, filePath = item.mediaFilePath, playNow = true)

        updateNotification()
    }

    private fun playNext() {
        index++
        if(index >= list.size) {
            index = 0
        }
        val item = list[index]
        title = item.title
        artist = item.artist
        albumCoverFilePath = item.albumCoverFilePath
        setSource(url = item.url, filePath = item.mediaFilePath, playNow = true)
        updateNotification()
    }

    @OptIn(UnstableApi::class)
    fun updateNotification() {

        val previousIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, com.amphi.music.MediaButtonReceiver::class.java).apply {
                action = "PLAY_PREVIOUS"
            }, PendingIntent.FLAG_IMMUTABLE
        )
        val nextIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, com.amphi.music.MediaButtonReceiver::class.java).apply {
                action = "PLAY_NEXT"
            }, PendingIntent.FLAG_IMMUTABLE
        )
        val playPauseIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, com.amphi.music.MediaButtonReceiver::class.java).apply {
                action = "PAUSE"
            }, PendingIntent.FLAG_IMMUTABLE
        )

        notificationBuilder = NotificationCompat.Builder(this, MusicApplication.MUSIC_NOTIFICATION_CHANNEL_ID)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentTitle(title)
            .setContentText(artist)
            .setSmallIcon(R.drawable.logo)
            .addAction(NotificationCompat.Action(R.drawable.previous, "Previous", previousIntent
            ))
            .addAction(NotificationCompat.Action( if(isPlaying) R.drawable.pause else R.drawable.play, "Pause", playPauseIntent
            ))
            .addAction(NotificationCompat.Action(R.drawable.next, "Pause", nextIntent
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