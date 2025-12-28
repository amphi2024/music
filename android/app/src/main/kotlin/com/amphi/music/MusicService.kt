package com.amphi.music

import android.Manifest
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.annotation.OptIn
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.net.toUri
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
    var playlistId = "!SONGS"
    var albumCoverFilePath: String? = null
    lateinit var mediaSessionCompat: MediaSessionCompat
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
        mediaSessionCompat = MediaSessionCompat(this, "MusicService")

        mediaSessionCompat.setCallback(object : MediaSessionCompat.Callback() {
            override fun onSeekTo(pos: Long) {
                player.seekTo(pos)
                updatePlaybackState()
            }
            override fun onPlay() {
                isPlaying = true
                player.play()
                updateNotification()
            }

            override fun onPause() {
                isPlaying = false
                player.pause()
                updateNotification()
            }

            override fun onSkipToNext() {
                playNext()
            }

            override fun onSkipToPrevious() {
                playPrevious()
            }
        })
        mediaSessionCompat.isActive = true


        player.addListener(object : Player.Listener{
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                this@MusicService.isPlaying = isPlaying
                updatePlaybackState()
            }
            override fun onPlaybackStateChanged(playbackState: Int) {
                if (playbackState == Player.STATE_ENDED) {
                    playNext()
                    methodChannel?.invokeMethod("sync_media_source_to_flutter", mapOf(
                        "index" to index,
                        "is_playing" to isPlaying
                    ))
                }
                updatePlaybackState()
            }
        })

        updateNotification()

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
                        methodChannel?.invokeMethod("sync_media_source_to_flutter", mapOf(
                            "index" to index,
                            "is_playing" to isPlaying
                        ))
                    }
                }
                "PLAY_NEXT" -> {
                    playNext()
                    methodChannel?.invokeMethod("sync_media_source_to_flutter", mapOf(
                        "index" to index,
                        "is_playing" to isPlaying
                    ))
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

        val mediaMetadata = androidx.media3.common.MediaMetadata.Builder()
            .setTitle(title)
            .setArtist(artist)
            .build()

        if(file.exists()) {

            val uri = Uri.fromFile(file)
            val mediaItem = MediaItem.Builder()
                .setUri(uri)
                .setMediaMetadata(mediaMetadata)
                .build()
            player.setMediaItem(mediaItem)
        }
        else {

            val mediaItem = MediaItem.Builder()
                .setUri(url.toUri())
                .setMediaMetadata(mediaMetadata)
                .build()

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

        methodChannel?.invokeMethod("sync_media_source_to_flutter", mapOf(
            "index" to index,
            "is_playing" to isPlaying
        ))

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

        methodChannel?.invokeMethod("sync_media_source_to_flutter", mapOf(
            "index" to index,
            "is_playing" to isPlaying
        ))
        updateNotification()
    }

    @OptIn(UnstableApi::class)
    fun updateNotification() {
        updatePlaybackState()

        val previousIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, MediaButtonReceiver::class.java).apply {
                action = "PLAY_PREVIOUS"
            }, PendingIntent.FLAG_IMMUTABLE
        )
        val nextIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, MediaButtonReceiver::class.java).apply {
                action = "PLAY_NEXT"
            }, PendingIntent.FLAG_IMMUTABLE
        )
        val playPauseIntent = PendingIntent.getBroadcast(
            this, 0, Intent(this, MediaButtonReceiver::class.java).apply {
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
            .addAction(NotificationCompat.Action(R.drawable.next, "Next", nextIntent
            ))
            .setOngoing(true)


        if(Build.VERSION.SDK_INT >= 34) {
            notificationBuilder.setStyle(
                androidx.media.app.NotificationCompat.MediaStyle()
                    .setMediaSession(mediaSessionCompat.sessionToken)
                    .setShowActionsInCompactView(0, 1, 2)
                    .setShowCancelButton(true)
            )
        }
        else {
            notificationBuilder.setStyle(MediaStyleNotificationHelper.MediaStyle(mediaSession).setShowActionsInCompactView(0, 1, 2))
        }

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
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            notificationManager.notify(1, notificationBuilder.build())
        }

    }

    override fun onDestroy() {
        super.onDestroy()
        player.release()
        mediaSessionCompat.release()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return binder
    }

    private fun updatePlaybackState() {
        val metadata = android.support.v4.media.MediaMetadataCompat.Builder()
            .putString(MediaMetadataCompat.METADATA_KEY_TITLE, title)
            .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, artist)
            .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, player.duration)
            .build()

        mediaSessionCompat.setMetadata(metadata)

        val state = if (isPlaying) PlaybackStateCompat.STATE_PLAYING else PlaybackStateCompat.STATE_PAUSED

        val playbackState = PlaybackStateCompat.Builder()
            .setActions(
                PlaybackStateCompat.ACTION_PLAY or
                        PlaybackStateCompat.ACTION_PAUSE or
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT or
                        PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS or
                        PlaybackStateCompat.ACTION_SEEK_TO
            )
            .setState(
                state,
                player.currentPosition,
                if (isPlaying) 1.0f else 0f
            )
            .setBufferedPosition(player.bufferedPosition)
            .build()

        mediaSessionCompat.setPlaybackState(playbackState)
    }

}