import 'package:audiotags/audiotags.dart';

class Music {
  Map<String, String> title = {};
  String artist = "";
  String album = "";
  String id = "";

  static Music created(Tag? tag) {
    var music = Music();
    music.title["default"] = tag?.title ?? "unknown";

    return music;
  }

  void save() {

  }
}

// package com.amphi.music.models.music
//
// import android.graphics.Bitmap
// import com.amphi.music.models.AppStorage
// import com.amphi.music.models.DateTime
// import com.amphi.music.utils.FilenameUtils
// import com.amphi.music.utils.JsonDecode
// import com.amphi.music.utils.getMutableStringMapOrDefault
// import com.amphi.music.utils.toJsonObject
// import org.json.JSONObject
// import java.io.File
//
// class Music(
// val title : MutableMap<String, String> = mutableMapOf(),
// val artist: String = "",
// val album: String = "",
// val composer: String = "",
// val lyricist: String = "",
// val duration: Long = 0,
// val genre: MutableMap<String, String> = mutableMapOf(),
// val year: Int? = null,
// var playedCount : Int = 0,
// val trackNumber: Int? = null,
// val files: MutableList<FileInMusic> = mutableListOf(),
// var path: String = "",
// var plainLyrics: String? = null,
// var created: DateTime = DateTime.now(),
// var modified: DateTime = DateTime.now(),
// val id: String
// ) {
//
// companion object {
//
// fun fromDirectory(directory: File) : Music {
//
// val infoFile = File("${directory.absolutePath}/info.json")
// val jsonObject = JsonDecode.tryJsonObjectFromFile(infoFile)
//
// val music = Music(
// title = jsonObject.getMutableStringMapOrDefault("title"),
// genre = jsonObject.getMutableStringMapOrDefault("genre"),
// id = directory.name
// )
//
// return music
// }
// }
//
// fun save() {
//
// val directory = File(path)
// if(!directory.exists()) {
// directory.mkdirs()
// }
//
// val infoFile = File("${path}/info.json")
// val jsonObject = JSONObject()
// jsonObject.put("title", title.toJsonObject())
// jsonObject.put("genre", genre.toJsonObject())
//
// infoFile.writeText(jsonObject.toString())
// }
// }


// package com.amphi.music.models.music
//
// import android.util.Log
// import com.amphi.music.utils.FilenameUtils
// import java.io.File
//
// class FileInMusic(
// val extension : String,
// val id: String
// ) {
//
// companion object {
// fun created(music: Music, file: File) : FileInMusic {
//
// val fileName = FilenameUtils.generatedFileName(".${file.extension}", music.path)
//
// val fileInMusic = FileInMusic(
// extension =".${file.extension}",
// id = fileName
// )
//
// val musicFile = File("${music.path}/${fileName}")
// musicFile.writeBytes(file.readBytes())
//
// return fileInMusic
// }
// }
//
//
// fun save() {
//
// }
// }