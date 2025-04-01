package com.amphi.music

import org.jaudiotagger.audio.AudioFileIO
import org.jaudiotagger.tag.FieldKey
import org.json.JSONObject
import java.io.File

    fun musicMetadata(filePath: String) : HashMap<String, Any> {
        val map: HashMap<String, Any> = HashMap()
        try {
            val tag = AudioFileIO.read(File(filePath)).tag
            map["title"] = tag.getFirst(FieldKey.TITLE) ?: ""
            map["artist"] = tag.getFirst(FieldKey.ARTIST) ?: ""
            map["albumArtist"] = tag.getFirst(FieldKey.ALBUM_ARTIST) ?: ""
            map["album"] = tag.getFirst(FieldKey.ALBUM) ?: ""
            map["genre"] = tag.getFirst(FieldKey.GENRE) ?: ""
            map["year"] = tag.getFirst(FieldKey.YEAR) ?: ""
            map["track"] = tag.getFirst(FieldKey.TRACK) ?: ""
            map["discNumber"] = tag.getFirst(FieldKey.DISC_NO) ?: ""
            map["comment"] = tag.getFirst(FieldKey.COMMENT) ?: ""
            map["composer"] = tag.getFirst(FieldKey.COMPOSER) ?: ""
            map["encoder"] = tag.getFirst(FieldKey.ENCODER) ?: ""
            map["lyricist"] = tag.getFirst(FieldKey.LYRICIST) ?: ""
            map["lyrics"] = tag.getFirst(FieldKey.LYRICS) ?: ""
        }
        catch (e: Exception) {
            return HashMap()
        }

        return map
    }

    fun albumArt(filePath: String) : ByteArray {
        try {
            val tag = AudioFileIO.read(File(filePath)).tag
            return tag.firstArtwork.binaryData
        }
        catch (e: Exception) {
            return ByteArray(0)
        }

    }