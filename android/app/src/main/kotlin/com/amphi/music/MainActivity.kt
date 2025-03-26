package com.amphi.music

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultDataSourceFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import com.amphi.music.NavigationBar.setNavigationBarColor
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File

class MainActivity: FlutterActivity() {

    val scope = CoroutineScope(Dispatchers.Main)
    var isTracking = false

    override fun onStart() {
        super.onStart()

        val serviceIntent = Intent(this, MusicService::class.java)
        startService(serviceIntent)
    }

    override fun onDestroy() {
        super.onDestroy()
        stopProgressTracking()
    }

    override fun onStop() {
        super.onStop()

        val serviceIntent = Intent(this, MusicService::class.java)
        stopService(serviceIntent)
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
                    MusicPlayer.resume(context)
                }

                "pause_music" -> {
                    MusicPlayer.pause(context)
                }

                "is_music_playing" -> {
                    result.success(MusicPlayer.getInstance(context).isPlaying)
                }
                "set_media_source" -> {
                    call.argument<String>("path")?.let { filePath ->
                        val uri = Uri.fromFile(File(filePath))

                        // Create a MediaItem using the local URI
                        val mediaItem = MediaItem.fromUri(uri)

                        // Prepare the media source
                        val mediaSource: MediaSource = ProgressiveMediaSource.Factory(DefaultDataSourceFactory(this, "exoMusicPlayer.getPlayer(context)"))
                            .createMediaSource(mediaItem)
                        MusicPlayer.getPlayer(context).setMediaItem(mediaItem)
                        MusicPlayer.getPlayer(context).prepare()

                        val playNow = call.argument<Any>("play_now")
                        if(playNow == true) {
                            MusicPlayer.getPlayer(context).play()
                        }
                    }
                }

                "apply_playback_position" -> {
                    val position = call.argument<Any>("position")
                    if(position is Int) {
                        MusicPlayer.getPlayer(context).seekTo(position.toLong())
                    }
                    else if(position is Long) {
                        MusicPlayer.getPlayer(context).seekTo(position)
                    }

                }

                "get_music_duration" -> {
                    result.success(MusicPlayer.getPlayer(context).duration)
                }

                "get_system_version" -> {
                    result.success(Build.VERSION.SDK_INT)
                }

                "configure_needs_bottom_padding" -> {
                    val navigationMode = Settings.Secure.getInt(contentResolver, "navigation_mode")
                    result.success(Build.VERSION.SDK_INT >= 35 && navigationMode != 2)
                }

                "get_music_metadata" -> {
                    result.success(call.argument<String>("path")?.let { MusicMetaDataUtils.musicMetadata(filePath = it) })
                }

                "get_album_cover" -> {
                    result.success(call.argument<String>("path")?.let { MusicMetaDataUtils.albumArt(filePath = it) })
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
                val currentPosition = MusicPlayer.getPlayer(context).currentPosition

                methodChannel.invokeMethod("on_playback_changed", mapOf(
                    "position" to currentPosition
                ))

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
