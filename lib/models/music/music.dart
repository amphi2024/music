import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';

import '../../utils/random_alphabet.dart';
import '../app_storage.dart';

class Music {

  Map<String, dynamic> data = {
    "title": <String, String>{},
    "genre": <String, String>{},
    "artist": "",
    "album": ""
  };

  Map<String, String> get title => data["title"];
  Map<String, String> get genre => data["genre"];
  set artist(value) => data["artist"] = value;
  String get artist => data["artist"];
  set album(value) => data["album"] = value;
  String get album => data["album"];
  String id = "";
  String path = "";

  static Music created({required Tag? tag,required String artistId, required String albumId}) {
    var music = Music();

    String alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.musicPath, alphabet);

    var directory = Directory(PathUtils.join(appStorage.musicPath , alphabet ,filename));
    directory.createSync(recursive: true);

    music.title["default"] = tag?.title ?? "unknown";
    music.id = filename;
    music.path = directory.path;
    music.artist = artistId;
    music.album = albumId;
    music.genre["default"] = tag?.genre ?? "unknown";

    return music;
  }

  void save() async {
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));
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