package com.amphi.music

import android.content.Context
import androidx.media3.exoplayer.ExoPlayer

class MusicPlayer private constructor(context: Context) {
    private val player: ExoPlayer = ExoPlayer.Builder(context).build()
    var isPlaying = false

    companion object {
        @Volatile
        private var INSTANCE: MusicPlayer? = null

        fun getInstance(context: Context): MusicPlayer {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: MusicPlayer(context).also { INSTANCE = it }
            }
        }

        fun getPlayer(context: Context): ExoPlayer {
            return getInstance(context).player
        }

        fun resume(context: Context) {
            getPlayer(context).play()

            getInstance(context).isPlaying = true
        }

        fun pause(context: Context) {
            getPlayer(context).pause()

            getInstance(context).isPlaying = false
        }
    }

}

