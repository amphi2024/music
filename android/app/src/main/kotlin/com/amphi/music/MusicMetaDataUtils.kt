package com.amphi.music

import org.jaudiotagger.audio.AudioFileIO
import org.jaudiotagger.tag.FieldKey
import org.json.JSONObject
import java.io.File

object MusicMetaDataUtils {
    fun musicMetadata(filePath: String) : String {
        val jsonObject = JSONObject()
        try {
            val tag = AudioFileIO.read(File(filePath)).tag
            jsonObject.put("title", tag.getFirst(FieldKey.TITLE))
            jsonObject.put("artist", tag.getFirst(FieldKey.ARTIST))
            jsonObject.put("albumArtist", tag.getFirst(FieldKey.ALBUM_ARTIST))
            jsonObject.put("album", tag.getFirst(FieldKey.ALBUM))
            jsonObject.put("genre", tag.getFirst(FieldKey.GENRE))
            jsonObject.put("year", tag.getFirst(FieldKey.YEAR))
            jsonObject.put("track", tag.getFirst(FieldKey.TRACK))
            jsonObject.put("discNumber", tag.getFirst(FieldKey.DISC_NO))
            jsonObject.put("comment", tag.getFirst(FieldKey.COMMENT))
            jsonObject.put("composer", tag.getFirst(FieldKey.COMPOSER))
            jsonObject.put("encoder", tag.getFirst(FieldKey.ENCODER))
            jsonObject.put("lyricist", tag.getFirst(FieldKey.LYRICIST))
            jsonObject.put("lyrics", tag.getFirst(FieldKey.LYRICS))
        }
        catch (e: Exception) {
            return "error"
        }

        return jsonObject.toString()
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
}