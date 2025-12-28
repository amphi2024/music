package com.amphi.music

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.provider.Settings
import android.view.WindowManager
import androidx.media3.common.util.UnstableApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class MainActivity : FlutterActivity() {

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
        methodChannel?.invokeMethod("sync_media_source_to_flutter", mapOf(
            "index" to (musicService?.index ?: 0),
            "is_playing" to (musicService?.isPlaying ?: false),
            "list" to (musicService?.list?.map { item ->
                item.songId
            } ?: listOf()),
            "playlist_id" to (musicService?.playlistId ?: "")
        ))
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
                    result.success(true)
                }

                "set_volume" -> {
                    val volume = call.argument<Double>("volume")!!
                    musicService?.player?.volume = volume.toFloat()
                    result.success(true)
                }

                "resume_music" -> {
                    musicService?.player?.play()
                    musicService?.isPlaying = true
                    musicService?.updateNotification()
                    result.success(true)
                }

                "pause_music" -> {
                    musicService?.player?.pause()
                    musicService?.isPlaying = false
                    musicService?.updateNotification()
                    result.success(true)
                }

                "is_music_playing" -> {
                    result.success(musicService?.isPlaying ?: false)
                }

                "set_media_source" -> {
                    val filePath = call.argument<String>("path")!!
                    val title = call.argument<String>("title")!!
                    val artist = call.argument<String>("artist")!!
                    val url = call.argument<String>("url")!!
                    val token = call.argument<String>("token")!!
                    val albumCoverPath = call.argument<String>("album_cover")
                    val playNow = call.argument<Boolean>("play_now")!!

                    musicService?.let { service ->

                        if(service.title != title || service.artist != artist) {
                            service.title = title
                            service.artist = artist
                            service.albumCoverFilePath = albumCoverPath
                            service.token = token
                            service.setSource(
                                url = url,
                                playNow = playNow,
                                filePath = filePath
                            )
                            service.updateNotification()
                        }
                    }
                    result.success(true)
                }

                "sync_playlist_state" -> {
                    musicService?.let {
                        it.list.clear()
                        val list = call.argument<List<HashMap<String, Any>>>("list")
                        val playMode = call.argument<Int>("play_mode")
                        val index = call.argument<Int>("index")
                        it.playMode = playMode!!
                        it.index = index!!
                        list?.forEach { map ->
                            val item = PlayableItem(
                                mediaFilePath = map["media_file_path"] as String,
                                url = map["url"] as String,
                                title = map["title"] as String,
                                artist = map["artist"] as String,
                                albumCoverFilePath = map["album_cover_file_path"] as? String,
                                songId = map["song_id"] as String
                            )
                            it.list.add(item)
                        }
                        it.playlistId = call.argument<String>("playlist_id")!!
                    }
                    result.success(true)
                }

                "apply_playback_position" -> {
                    val position = call.argument<Any>("position")
                    if (position is Int) {
                        musicService?.player?.seekTo(position.toLong())
                    } else if (position is Long) {
                        musicService?.player?.seekTo(position)
                    }
                    result.success(true)
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

                "sync_media_source_to_native" -> {
                    val index = call.argument<Int>("index")!!
                    val isPlaying = call.argument<Boolean>("is_playing")!!
                    musicService?.isPlaying = isPlaying
                    musicService?.index = index
                    result.success(true)
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
                    if (currentPosition > 0) {
                        methodChannel.invokeMethod(
                            "on_playback_changed", mapOf(
                                "position" to currentPosition
                            )
                        )
                    }
                }
                delay(500)
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
