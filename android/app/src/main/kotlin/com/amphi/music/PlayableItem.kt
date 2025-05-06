package com.amphi.music

import org.json.JSONObject

data class PlayableItem(
    val mediaFilePath: String,
    val url: String,
    val title: String,
    val artist: String,
    val albumCoverFilePath: String?,
    val songId: String
) {

    fun toMap() : HashMap<String, String> {
        return hashMapOf(
            "media_file_path" to mediaFilePath,
            "url" to url
        )
    }
}
