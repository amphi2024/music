package com.amphi.music

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.provider.Settings
import android.view.WindowManager
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File

class MainActivity: FlutterActivity() {

    private val scope = CoroutineScope(Dispatchers.Main)
    private var isTracking = false
    private var musicService: MusicService? = null
    private var isBound = false

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as MusicService.LocalBinder
            musicService = binder.getService()
            isBound = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            isBound = false
        }
    }

    private lateinit var serviceIntent: Intent

    override fun onStart() {
        super.onStart()
        serviceIntent = Intent(this, MusicService::class.java)

        androidx.core.content.ContextCompat.startForegroundService(this, serviceIntent)
        //startForegroundService(serviceIntent)
        bindService(serviceIntent, connection, Context.BIND_AUTO_CREATE)
    }

    override fun onDestroy() {
        super.onDestroy()
        stopProgressTracking()
    }

    override fun onStop() {
        super.onStop()

        unbindService(connection)
    }

    override fun onResume() {
        super.onResume()
        setNavigationBarColor(
            window = window,
            navigationBarColor = navigationBarColor,
            iosLikeUi = iosLikeUi
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= 29) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            )
        }
    }

    private var methodChannel: MethodChannel? = null
    private var storagePath: String? = null
    private var navigationBarColor: Int = 0
    private var iosLikeUi: Boolean = false

    @UnstableApi
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        storagePath = filesDir.path
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel!!.setMethodCallHandler { call, result ->
            val window = this@MainActivity.window
            musicService?.methodChannel = methodChannel
            when (call.method) {
                "set_navigation_bar_color" -> {
                    val color = call.argument<Long>("color")
                    val iosUi = call.argument<Boolean>("transparent_navigation_bar")

                    if (color != null && iosUi != null) {
                        iosLikeUi = iosUi
                        navigationBarColor = color.toInt()

                        setNavigationBarColor(
                            window = window,
                            navigationBarColor = navigationBarColor,
                            iosLikeUi = iosLikeUi
                        )

                    }

                }

                "resume_music" -> {
                    musicService?.player?.play()
                    musicService?.isPlaying = true
                    musicService?.updateNotification()
                }

                "pause_music" -> {
                    musicService?.player?.pause()
                    musicService?.isPlaying = false
                    musicService?.updateNotification()
                }

                "is_music_playing" -> {
                    result.success(musicService?.isPlaying ?: false)
                }
                "set_media_source" -> {
                    call.argument<String>("path")?.let { filePath ->
                        val uri = Uri.fromFile(File(filePath))

                        // Create a MediaItem using the local URI
                        val mediaItem = MediaItem.fromUri(uri)

                        // Prepare the media source
//                        val mediaSource: MediaSource = ProgressiveMediaSource.Factory(DefaultDataSourceFactory(this, "exoMusicPlayer.getPlayer(context)"))
//                            .createMediaSource(mediaItem)
                        musicService?.let { service ->
                            service.player.setMediaItem(mediaItem)
                            service.player.prepare()
                            service.title = call.argument<String>("title") ?: ""
                            service.artist = call.argument<String>("artist") ?: ""
                            service.albumCoverFilePath = call.argument<String>("album_cover")
                            val playNow = call.argument<Any>("play_now")
                            if(playNow == true) {
                                service.player.play()
                                service.isPlaying = true
                            }
                            service.updateNotification()
                        }


                    }
                }

                "apply_playback_position" -> {
                    val position = call.argument<Any>("position")
                    if(position is Int) {
                        musicService?.player?.seekTo(position.toLong())
                    }
                    else if(position is Long) {
                        musicService?.player?.seekTo(position)
                    }

                }

                "get_music_duration" -> {
                    result.success(musicService?.player?.duration ?: 0)
                }

                "get_system_version" -> {
                    result.success(Build.VERSION.SDK_INT)
                }

                "configure_needs_bottom_padding" -> {
                    val navigationMode = Settings.Secure.getInt(contentResolver, "navigation_mode")
                    result.success(Build.VERSION.SDK_INT >= 35 && navigationMode != 2)
                }

                "get_music_metadata" -> {
                    result.success(call.argument<String>("path")?.let { musicMetadata(filePath = it) })
                }

                "get_album_cover" -> {
                    result.success(call.argument<String>("path")?.let { albumArt(filePath = it) })
                }

                else -> result.notImplemented()
            }
        }

        startProgressTracking(methodChannel!!)
    }

    private fun startProgressTracking(methodChannel: MethodChannel) {
        isTracking = true
        scope.launch {
            while (isTracking) {
                musicService?.let { service ->
                    val currentPosition = service.player.currentPosition
                    if(currentPosition > 0) {
                        methodChannel.invokeMethod(
                            "on_playback_changed", mapOf(
                                "position" to currentPosition
                            )
                        )
                    }
                }
                delay(1000L)
            }
        }
    }

    private fun stopProgressTracking() {
        isTracking = false
        scope.cancel()
    }

    companion object {
        private const val CHANNEL = "music_method_channel"
    }
}
